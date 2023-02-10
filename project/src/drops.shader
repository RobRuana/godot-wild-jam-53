shader_type canvas_item;


uniform float blur = 5.0;
uniform float desaturate = 1.0;
uniform float fade_in_duration = 10.0;
uniform float lightning: hint_range(-1.0, 1.0) = 0.0;
uniform sampler2D drops_texture;


// Generic algorithm to desaturate images used in most game engines
vec4 generic_desaturate(vec4 color, float factor) {
	vec3 lum = vec3(0.299, 0.587, 0.114);
	vec3 gray = vec3(dot(lum, color.rgb));
	return vec4(mix(color.rgb, gray, factor), color.a);
}


vec2 distort(vec2 p, vec2 normal, float distortion) {
	float d = length(normal);
	float z = sqrt(distortion + d * d * -distortion);
	float r = atan(d, z) / 3.1415926535;
	float phi = atan(normal.y, normal.x);
	return p + vec2(r * cos(phi) + 0.5, r * sin(phi) + 0.5);
}


void fragment() {
	vec2 drops_uv = UV;

	vec4 drops_color = texture(drops_texture, drops_uv);
	
	float blur_factor = 1.0 - max(max(drops_color.r, drops_color.g), drops_color.b);
	float drops_blur = mix(0.0, blur, blur_factor);

	vec2 normal = (drops_color.rg - vec2(0.5)) * 0.5;
	float strength = (1.0 - drops_color.b) * (1.0 - blur_factor);
	vec2 screen_uv = UV + (normal * strength);
	vec4 screen_color = textureLod(TEXTURE, screen_uv, drops_blur);

	// desaturate
	screen_color = generic_desaturate(screen_color, desaturate);

	// fade in at the start
	float fade = smoothstep(0.0, fade_in_duration, TIME);

	// lightning
	screen_color *= 1.0 + (lightning * fade);

	// vignette
	screen_color.rgb *= 1.0 - dot(UV - 0.5, UV);

	// composite start and end fade
	screen_color *= fade;

	COLOR = screen_color;
}
