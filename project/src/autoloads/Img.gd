extends Node

const RECT_ZERO: Rect2 = Rect2(0.0, 0.0, 0.0, 0.0)
const TEXTURE_FLAG_FILTER = 4  # from visual_server.h in godot


func get_display_size(sprite: Sprite) -> Vector2:
	if sprite.region_enabled:
		return sprite.region_rect.size
	else:
		return Vector2(sprite.texture.get_width(), sprite.texture.get_height())


func is_invisible(image: Image, min_alpha: float = 0.0) -> bool:
	if is_zero_approx(min_alpha):
		return image.is_invisible()

	image.lock()
	for x in image.get_width():
		for y in image.get_height():
			var pixel: Color = image.get_pixel(x, y)
			if pixel.a >= min_alpha or is_equal_approx(pixel.a, min_alpha):
				image.unlock()
				return false
	image.unlock()
	return true


func save_stex(image: Image, save_path: String, filter: bool = false) -> int:
	var pngdata: PoolByteArray = image.save_png_to_buffer()
	var pnglen: int = pngdata.size()

	# Before Image.save_png_to_buffer() method existed, needed to save png to tmp file
#	var tmppng = "%s-tmp.png" % [save_path]
#	image.save_png(tmppng)
#	var pngf = File.new()
#	pngf.open(tmppng, File.READ)
#	var pnglen = pngf.get_len()
#	var pngdata = pngf.get_buffer(pnglen)
#	pngf.close()
#	Directory.new().remove(tmppng)

	var stexf: File = File.new()
	var err: int = stexf.open(save_path, File.WRITE)
	if err != OK:
		push_error("Failed to open stex file for writing [%s]: %s" % [err, save_path])
		return err
	stexf.store_8(0x47) # G
	stexf.store_8(0x44) # D
	stexf.store_8(0x53) # S
	stexf.store_8(0x54) # T
	stexf.store_32(image.get_width())
	stexf.store_32(image.get_height())
	stexf.store_32(TEXTURE_FLAG_FILTER if filter else 0)
	stexf.store_32(0x07100000) # data format
	stexf.store_32(1) # nr mipmaps
	stexf.store_32(pnglen + 6)
	stexf.store_8(0x50) # P
	stexf.store_8(0x4e) # N
	stexf.store_8(0x47) # G
	stexf.store_8(0x20) # space
	stexf.store_buffer(pngdata)
	stexf.close()
	return err


func image_from_texture(texture: Texture, region: Rect2 = RECT_ZERO) -> Image:
#	var image: Image = Image.new()
	var texture_image: Image = texture.get_data()
	if region != RECT_ZERO:
		texture_image = texture_image.get_rect(Rect2(region.position, region.size.abs()))
		if region.size.x < 0.0:
			texture_image.flip_x()
		if region.size.y < 0.0:
			texture_image.flip_y()
	return texture_image
#	texture_image.lock()
#	if region == RECT_ZERO:
#		var texture_width: int = texture.get_width()
#		var texture_height: int = texture.get_height()
#		image.create(texture_width, texture_height, false, texture_image.get_format())
#		image.lock()
#		image.blit_rect_mask(
#			texture_image,
#			texture_image,
#			Rect2(0.0, 0.0, texture_width, texture_height),
#			Vector2.ZERO
#		)
#	else:
#		var texture_width: int = int(ceil(region.size.x))
#		var texture_height: int = int(ceil(region.size.y))
#		image.create(texture_width, texture_height, false, texture_image.get_format())
#		image.lock()
#		image.blit_rect_mask(
#			texture_image,
#			texture_image,
#			region,
#			Vector2.ZERO
#		)
#	image.unlock()
#	texture_image.unlock()
#	return image


func image_texture_from_texture(texture: Texture, region: Rect2 = RECT_ZERO) -> ImageTexture:
	var image: Image = image_from_texture(texture, region)
	var image_texture: ImageTexture = ImageTexture.new()
	image_texture.create_from_image(image, 0)
	return image_texture


func image_from_sprite(sprite: Sprite, region: Rect2 = RECT_ZERO) -> Image:
	var sprite_region: Rect2 = sprite.region_rect if sprite.region_enabled else RECT_ZERO
	var texture_region: Rect2 = Rect2(sprite_region.position + region.position, region.size)
	if texture_region != RECT_ZERO:
		if sprite.global_transform.x.x == -1:
			texture_region.size.x = -texture_region.size.x
	return image_from_texture(sprite.texture, texture_region)


func image_texture_from_sprite(sprite: Sprite, region: Rect2 = RECT_ZERO) -> ImageTexture:
	var sprite_region: Rect2 = sprite.region_rect if sprite.region_enabled else RECT_ZERO
	var texture_region: Rect2 = Rect2(sprite_region.position + region.position, region.size)
	return image_texture_from_texture(sprite.texture, texture_region)


func adjust_alpha(image: Image, percent: float) -> Image:
	var dst_image: Image = Image.new()
	dst_image.create(image.get_width(), image.get_height(), image.has_mipmaps(), image.get_format())
	dst_image.lock()
	image.lock()
	for x in image.get_width():
		for y in image.get_height():
			var pixel: Color = image.get_pixel(x, y)
			pixel.a = clamp(pixel.a * percent, 0.0, 1.0)
			dst_image.set_pixel(x, y, pixel)
	dst_image.unlock()
	image.unlock()
	return dst_image


func render_sprite_to_image(
	src: Sprite,
	dst: Image,
	src_rect: Rect2 = RECT_ZERO,
	dst_point: Vector2 = Vector2.ZERO,
	use_fill_color: bool = false,
	use_outline_color_alt: bool = false
) -> Image:

	var src_image: Image = src.texture.get_data()
	var src_sprite_region: Rect2 = src.region_rect if src.region_enabled else RECT_ZERO
	var src_region: Rect2 = Rect2(src_sprite_region.position + src_rect.position, src_rect.size)

	var src_position: Vector2 = src_region.position
	var src_size: Vector2 = src_region.size
	if src_region == RECT_ZERO:
		src_size = Vector2(src_image.get_width(), src_image.get_height())

	dst.lock()
	src_image.lock()
	if src.material:
		var outline_color: Color = get_shader_param(src.material, "outline_color", Color.black)
		var outline_mix: float = get_shader_param(src.material, "outline_mix", 0.0)
		var outline_color_alt: Color = get_shader_param(src.material, "outline_color_alt", Color.white)
		var outline_color_alt_mix: float = get_shader_param(src.material, "outline_color_alt_mix", 0.0) if use_outline_color_alt else 0.0
		var outline_corners: float = get_shader_param(src.material, "outline_corners", 0.0)
		var fill_color: Color = get_shader_param(src.material, "fill_color", Color.white)
		var fill_mix: float = get_shader_param(src.material, "fill_mix", 0.0) if use_fill_color else 0.0
		var palette_texture: Texture = get_shader_param(src.material, "palette_texture", null)
		var palette_image: Image = null if palette_texture == null else palette_texture.get_data()
		var palette_mix: float = get_shader_param(src.material, "palette_mix", 0.0)
		var palette_texture_alt: Texture = get_shader_param(src.material, "palette_texture_alt", null)
		var palette_image_alt: Image = null if palette_texture_alt == null else palette_texture_alt.get_data()
		var palette_texture_alt_mix: float = get_shader_param(src.material, "palette_texture_alt_mix", 0.0)
		for y in range(src_size.y):
			for x in range(src_size.x):
				var src_color: Color = swap_color(
					src_image,
					Vector2(int(src_position.x) + x, int(src_position.y) + y),
					outline_color,
					outline_mix,
					outline_color_alt,
					outline_color_alt_mix,
					outline_corners,
					fill_color,
					fill_mix,
					palette_image,
					palette_mix,
					palette_image_alt,
					palette_texture_alt_mix
				)
				dst.set_pixel(int(dst_point.x) + x, int(dst_point.y) + y, src_color)
	else:
		dst.blit_rect_mask(src_image, src_image, Rect2(src_position, src_size), dst_point)
	dst.unlock()
	src_image.unlock()
	return dst


func get_shader_param(material: Material, name: String, default_value):
	var value = material.get_shader_param(name)
	if value == null:
		return default_value
	return value


func get_pixelv_alpha(tex: Image, uv: Vector2) -> float:
	if uv.x < 0.0 or uv.y < 0.0 or uv.x >= tex.get_width() or uv.y >= tex.get_height():
		return 0.0
	return tex.get_pixelv(uv).a


func get_outline_color(
	tex: Image,
	uv: Vector2,
	sample_color: Color,
	outline_color: Color = Color.black,
	outline_mix: float = 0.0,
	outline_color_alt: Color = Color.white,
	outline_color_alt_mix: float = 0.0,
	outline_corners: float = 0.0,
	outline_pixel_width: Vector2 = Vector2(1.0, 1.0)
) -> Color:
	if outline_mix == 0.0:
		return sample_color

	var outline_center_strength: float = sample_color.a
	outline_center_strength += get_pixelv_alpha(tex, uv + Vector2(0.0, -outline_pixel_width.y))
	outline_center_strength += get_pixelv_alpha(tex, uv + Vector2(outline_pixel_width.x, 0.0))
	outline_center_strength += get_pixelv_alpha(tex, uv + Vector2(0.0, outline_pixel_width.y))
	outline_center_strength += get_pixelv_alpha(tex, uv + Vector2(-outline_pixel_width.x, 0.0))
	outline_center_strength = clamp(outline_center_strength, 0.0, 1.0)

	var outline_corner_strength: float = sample_color.a
	if outline_corners > 0.0:
		outline_corner_strength += get_pixelv_alpha(tex, uv + Vector2(-outline_pixel_width.x, -outline_pixel_width.y)) * outline_corners
		outline_corner_strength += get_pixelv_alpha(tex, uv + Vector2(outline_pixel_width.x, -outline_pixel_width.y)) * outline_corners
		outline_corner_strength += get_pixelv_alpha(tex, uv + Vector2(outline_pixel_width.x, outline_pixel_width.y)) * outline_corners
		outline_corner_strength += get_pixelv_alpha(tex, uv + Vector2(-outline_pixel_width.x, outline_pixel_width.y)) * outline_corners
		outline_corner_strength = clamp(outline_corner_strength, 0.0, 1.0)

	var outline_strength: float = lerp(0.0, clamp(outline_center_strength + outline_corner_strength, 0.0, 1.0), outline_mix)
	var alpha: float = max(sample_color.a, lerp(sample_color.a, outline_color.a, outline_strength))

	var outline: Color = lerp(outline_color, outline_color_alt, outline_color_alt_mix)
	var final_color: Color = lerp(outline, sample_color, sample_color.a)
	final_color.a = clamp(alpha, 0.0, 1.0)
	return final_color


func color_glow(color: Color, glow: float) -> Color:
	return Color.from_hsv(
		color.h,
		color.s,
		glow + 1.0 if glow > 0.0 else color.v,
		color.a
	)


func swap_color(
	tex: Image,
	uv: Vector2,
	outline_color: Color = Color.black,
	outline_mix: float = 0.0,
	outline_color_alt: Color = Color.white,
	outline_color_alt_mix: float = 0.0,
	outline_corners: float = 0.0,
	fill_color: Color = Color.white,
	fill_mix: float = 0.0,
	palette_texture: Image = null,
	palette_mix: float = 0.0,
	palette_texture_alt: Image = null,
	palette_texture_alt_mix: float = 0.0,
	pixel_size: Vector2 = Vector2(1.0, 1.0)
) -> Color:
	var sprite_color: Color = tex.get_pixelv(uv)
	if sprite_color.a == 0.0:
		pass

	var texture_color: Color = sprite_color
	if palette_texture != null and palette_mix > 0.0:
		var palette_offset: int = int(ceil(sprite_color.r * float(palette_texture.get_width() - 1)))
		palette_texture.lock()
		var palette_color: Color = palette_texture.get_pixel(palette_offset, 0)
		palette_texture.unlock()
		if palette_texture_alt != null and palette_texture_alt_mix > 0.0:
			palette_texture_alt.lock()
			palette_color = lerp(
				palette_color,
				palette_texture_alt.get_pixel(palette_offset, 0),
				palette_texture_alt_mix
			)
			palette_texture_alt.unlock()
		texture_color = lerp(sprite_color, palette_color, palette_mix)

	var sample_color: Color = lerp(texture_color, fill_color, fill_mix)
	sample_color.a = min(sprite_color.a, fill_color.a)

	return get_outline_color(
		tex,
		uv,
		sample_color,
		outline_color,
		outline_mix,
		outline_color_alt,
		outline_color_alt_mix,
		outline_corners,
		pixel_size
	)


func get_debug_sprite(source_sprite: Sprite) -> Sprite:
	var debug_sprite: Sprite = Sprite.new()
	debug_sprite.texture = source_sprite.texture
	debug_sprite.region_enabled = source_sprite.region_enabled
	debug_sprite.region_rect = source_sprite.region_rect
	debug_sprite.offset = source_sprite.offset
	debug_sprite.centered = source_sprite.centered
	debug_sprite.flip_h = source_sprite.flip_h
	debug_sprite.flip_v = source_sprite.flip_v
	debug_sprite.position = source_sprite.global_position
	debug_sprite.modulate = Color(1.0, 4.0, 4.0, 0.5)
	return debug_sprite
