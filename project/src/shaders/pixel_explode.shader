shader_type particles;
// this shader was converted from a ParticlesMaterial
// you can find the explosion related parts by searching \"explosion\"
uniform vec3 direction = vec3(1, 0 , 0);
uniform float spread = 0.0;
uniform float flatness = 0.0;
uniform float initial_linear_velocity = 10.0;
uniform float initial_angle = 0.0;
uniform float angular_velocity = 0.0;
uniform float orbit_velocity = 0.0;
uniform float linear_accel = 0.0;
uniform float radial_accel = 0.0;
uniform float tangent_accel = 0.0;
uniform float damping = 0.0;
uniform float scale = 0.5;
uniform float hue_variation = 0.0;
uniform float anim_speed = 0.0;
uniform float anim_offset = 0.0;
uniform float initial_linear_velocity_random = 1.0;
uniform float initial_angle_random = 0.0;
uniform float angular_velocity_random = 0.0;
uniform float orbit_velocity_random = 0.0;
uniform float linear_accel_random = 0.0;
uniform float radial_accel_random = 0.0;
uniform float tangent_accel_random = 0.0;
uniform float damping_random = 0.0;
uniform float scale_random = 0.0;
uniform float hue_variation_random = 0.0;
uniform float anim_speed_random = 0.0;
uniform float anim_offset_random = 0.0;
uniform float lifetime_randomness = 0.0;
uniform vec3 emission_box_extents = vec3( 1, 1, 1 );
uniform vec4 color_value : hint_color = vec4( 1, 1, 1, 1 );
uniform int trail_divisor = 1;
uniform vec3 gravity = vec3( 0, 0, 0 );

uniform sampler2D sprite; // sprite that will explode
uniform vec2 sprite_region_position = vec2(0.0, 0.0);
uniform vec2 sprite_region_size = vec2(1.0, 1.0);
uniform int sprite_copies; // Number of stacked sprites that will explode (more usually looks better, sense of depth)
uniform vec2 sprite_velocity = vec2(0.0, 0.0);
uniform vec2 pixels_per_particle = vec2(1.0, 1.0); // number of pixels per particle
uniform vec2 emission_origin = vec2(0.0, 0.0);
uniform vec2 emission_direction = vec2(0.0, 1.0);
uniform float fade_delay = 5.0;

uniform float outline_mix: hint_range(0.0, 1.0) = 0.0;
uniform float outline_corners = 0.0;
uniform vec4 outline_color: hint_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform vec4 outline_color_alt: hint_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float outline_color_alt_mix: hint_range(0.0, 1.0) = 0.0;
uniform float fill_mix: hint_range(0.0, 1.0) = 0.0;
uniform vec4 fill_color: hint_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float palette_mix: hint_range(0.0, 1.0) = 0.0;
uniform sampler2D palette_texture; // Palette, should be 1 pixel tall
uniform sampler2D palette_texture_alt;
uniform float palette_texture_alt_mix: hint_range(0.0, 1.0) = 0.0;
uniform float modulate_strength: hint_range(0.0, 1.0) = 0.75;

vec4 modulate_color(vec4 source_color, vec4 modulate) {
	return source_color * vec4(mix(vec3(1.0), modulate.rgb, modulate_strength), modulate.a);
}

vec4 get_outline_color(sampler2D tex, vec2 uv, vec2 outline_pixel_width, vec3 sample_color, float sample_alpha) {
	float outline_center_strength = sample_alpha;
	outline_center_strength += texture(tex, uv + vec2(0.0, -outline_pixel_width.y)).a;
	outline_center_strength += texture(tex, uv + vec2(outline_pixel_width.x, 0.0)).a;
	outline_center_strength += texture(tex, uv + vec2(0.0, outline_pixel_width.y)).a;
	outline_center_strength += texture(tex, uv + vec2(-outline_pixel_width.x, 0.0)).a;
	outline_center_strength = clamp(outline_center_strength, 0.0, 1.0);
	
	float outline_corner_strength = sample_alpha;
	outline_corner_strength += texture(tex, uv + vec2(-outline_pixel_width.x, -outline_pixel_width.y)).a * outline_corners;
	outline_corner_strength += texture(tex, uv + vec2(outline_pixel_width.x, -outline_pixel_width.y)).a * outline_corners;
	outline_corner_strength += texture(tex, uv + vec2(outline_pixel_width.x, outline_pixel_width.y)).a * outline_corners;
	outline_corner_strength += texture(tex, uv + vec2(-outline_pixel_width.x, outline_pixel_width.y)).a * outline_corners;
	outline_corner_strength = clamp(outline_corner_strength, 0.0, 1.0);
	
	float outline_strength = mix(0.0, clamp(outline_center_strength + outline_corner_strength, 0.0, 1.0), outline_mix);
	float alpha = max(sample_alpha, mix(sample_alpha, outline_color.a, outline_strength));

	vec4 outline = mix(outline_color, outline_color_alt, outline_color_alt_mix);
	vec3 final_color = mix(outline.rgb, sample_color.rgb, sample_alpha);
	
	return vec4(final_color, clamp(alpha, 0.0, 1.0));
}

vec4 swap_color(vec2 pixel_size, sampler2D tex, vec2 uv) {
	vec4 sprite_color = texture(tex, uv);

	float palette_offset = sprite_color.r;
	vec4 palette_color = mix(
		texture(palette_texture, vec2(palette_offset, 0.0)),
		texture(palette_texture_alt, vec2(palette_offset, 0.0)),
		palette_texture_alt_mix
	);
	vec4 texture_color = mix(sprite_color, palette_color, palette_mix);
	vec3 sample_color = mix(texture_color.rgb, fill_color.rgb, fill_mix);
	float sample_alpha = min(sprite_color.a, fill_color.a);
	
	return get_outline_color(tex, uv, pixel_size, sample_color, sample_alpha);
}

float rand_from_seed(inout uint seed) {
	int k;
	int s = int(seed);
	if (s == 0)
	s = 305420679;
	k = s / 127773;
	s = 16807 * (s - k * 127773) - 2836 * k;
	if (s < 0)
		s += 2147483647;
	seed = uint(s);
	return float(seed % uint(65536)) / 65535.0;
}

float rand_from_seed_m1_p1(inout uint seed) {
	return rand_from_seed(seed) * 2.0 - 1.0;
}

uint hash(uint x) {
	x = ((x >> uint(16)) ^ x) * uint(73244475);
	x = ((x >> uint(16)) ^ x) * uint(73244475);
	x = (x >> uint(16)) ^ x;
	return x;
}

void vertex() {
	uint base_number = NUMBER / uint(trail_divisor);
	uint alt_seed = hash(base_number + uint(1) + RANDOM_SEED);
	float angle_rand = rand_from_seed(alt_seed);
	float scale_rand = rand_from_seed(alt_seed);
	float hue_rot_rand = rand_from_seed(alt_seed);
	float anim_offset_rand = rand_from_seed(alt_seed);
	float pi = 3.14159;
	float degree_to_rad = pi / 180.0;

	bool restart = false;
	if (CUSTOM.y > CUSTOM.w) {
		restart = true;
	}

	vec2 texture_size = vec2(textureSize(sprite, 0));
	float particle_columns = ceil(sprite_region_size.x / pixels_per_particle.x);
	float particle_rows = ceil(sprite_region_size.y / pixels_per_particle.y);
	float index = floor(float(INDEX) / float(sprite_copies));
	vec2 particle_position = vec2(
		(float(uint(index) % uint(particle_columns)) - (particle_columns * 0.5) + 0.5) * pixels_per_particle.x,
		(floor((float(index) / particle_columns)) - (particle_rows * 0.5) + 0.5) * pixels_per_particle.y
	);
	vec2 uv_particle_position = vec2(
		mod(sprite_region_position.x + (sprite_region_size.x * 0.5) + particle_position.x, texture_size.x),
		mod(sprite_region_position.y + (sprite_region_size.y * 0.5) + particle_position.y, texture_size.y)
	);
	vec2 uv = uv_particle_position / texture_size;
	vec4 sprite_color = swap_color(1.0 / texture_size, sprite, uv);

	if (RESTART || restart) {
		float tex_linear_velocity = 0.0;
		float tex_angle = 0.0;
		float tex_anim_offset = 0.0;
		float spread_rad = spread * degree_to_rad;
		float angle1_rad = rand_from_seed_m1_p1(alt_seed) * spread_rad;
		angle1_rad += direction.x != 0.0 ? atan(direction.y, direction.x) : sign(direction.y) * (pi / 2.0);
		vec3 rot = vec3(cos(angle1_rad), sin(angle1_rad), 0.0);
		VELOCITY = rot * initial_linear_velocity * mix(1.0, rand_from_seed(alt_seed), initial_linear_velocity_random);
		float base_angle = (initial_angle + tex_angle) * mix(1.0, angle_rand, initial_angle_random);
		CUSTOM.x = base_angle * degree_to_rad;
		CUSTOM.y = 0.0;
		CUSTOM.w = (1.0 - lifetime_randomness * rand_from_seed(alt_seed));
		CUSTOM.z = (anim_offset + tex_anim_offset) * mix(1.0, anim_offset_rand, anim_offset_random);
//		TRANSFORM[3].xyz = vec3(rand_from_seed(alt_seed) * 2.0 - 1.0, rand_from_seed(alt_seed) * 2.0 - 1.0, rand_from_seed(alt_seed) * 2.0 - 1.0) * emission_box_extents;

		TRANSFORM[3].xyz = vec3(
			particle_position.x,
			particle_position.y,
			0.0
		);
//		VELOCITY = (EMISSION_TRANSFORM * vec4(VELOCITY, 0.0)).xyz;
		TRANSFORM = EMISSION_TRANSFORM * TRANSFORM;
//		VELOCITY.z = 0.0;
//		TRANSFORM[3].z = 0.0;

		// Explosion code starts here
		vec2 em_direction = emission_direction; // (EMISSION_TRANSFORM * vec4(emission_direction, 0.0, 0.0)).xy;
		vec2 em_origin = (EMISSION_TRANSFORM * vec4(emission_origin, 0.0, 0.0)).xy;
		// vec2(0.5, 0.5) is the UV coordinate of the explosion's origin
//		vec4 sprite_color = texture(sprite, particle_position / texture_size + em_origin);
//		vec4 sprite_color = texture(sprite, uv);
		COLOR = sprite_color;
//		COLOR = vec4(1, 0, 0, 1.0);
		// particle movement
		vec2 particle_vector = particle_position - em_origin;
		vec2 particle_normalized = normalize(particle_vector);
		float particle_distance = length(particle_vector);
		float dot_product = 0.5 + (0.5 * abs(dot(em_direction, particle_normalized)));
		float min_dimension = min(sprite_region_size.x, sprite_region_size.y);
		vec2 distance_vector = particle_normalized * min(particle_distance, min_dimension);
		vec2 velocity = (
			distance_vector * dot_product * initial_linear_velocity * mix(1.0, rand_from_seed(alt_seed), initial_linear_velocity_random)
			+ (EMISSION_TRANSFORM * vec4(sprite_velocity, 0.0, 0.0)).xy
		);
		float angle = 0.3926990817 * mix(0.0, angle_rand * 2.0 - 1.0, initial_angle_random);
		velocity = vec2(velocity.x * cos(angle) - velocity.y * sin(angle), velocity.x * sin(angle) + velocity.y * cos(angle));
		VELOCITY = (EMISSION_TRANSFORM * vec4(velocity, 0.0, 0.0)).xyz;
		// ignore transparent pixels
		ACTIVE = (sprite_color.a != 0.0);
//		if (sprite_color.a == 0.0) { COLOR = vec4(1.0, 0.0, 1.0, 1.0); }
	} else {
		CUSTOM.y += DELTA / LIFETIME;
		float tex_linear_velocity = 0.0;
		float tex_orbit_velocity = 0.0;
		float tex_angular_velocity = 0.0;
		float tex_linear_accel = 0.0;
		float tex_radial_accel = 0.0;
		float tex_tangent_accel = 0.0;
		float tex_damping = 0.0;
		float tex_angle = 0.0;
		float tex_anim_speed = 0.0;
		float tex_anim_offset = 0.0;
		vec3 force = gravity;
		vec3 pos = TRANSFORM[3].xyz;
		pos.z = 0.0;
		// apply linear acceleration
		force += length(VELOCITY) > 0.0 ? normalize(VELOCITY) * (linear_accel + tex_linear_accel) * mix(1.0, rand_from_seed(alt_seed), linear_accel_random) : vec3(0.0);
		// apply radial acceleration
		vec3 org = EMISSION_TRANSFORM[3].xyz;
		vec3 diff = pos - org;
		force += length(diff) > 0.0 ? normalize(diff) * (radial_accel + tex_radial_accel) * mix(1.0, rand_from_seed(alt_seed), radial_accel_random) : vec3(0.0);
		// apply tangential acceleration;
		force += length(diff.yx) > 0.0 ? vec3(normalize(diff.yx * vec2(-1.0, 1.0)), 0.0) * ((tangent_accel + tex_tangent_accel) * mix(1.0, rand_from_seed(alt_seed), tangent_accel_random)) : vec3(0.0);
		// apply attractor forces
		VELOCITY += force * DELTA;
		// orbit velocity
		float orbit_amount = (orbit_velocity + tex_orbit_velocity) * mix(1.0, rand_from_seed(alt_seed), orbit_velocity_random);
		if (orbit_amount != 0.0) {
			float ang = orbit_amount * DELTA * pi * 2.0;
			mat2 rot = mat2(vec2(cos(ang), -sin(ang)), vec2(sin(ang), cos(ang)));
			TRANSFORM[3].xy -= diff.xy;
			TRANSFORM[3].xy += rot * diff.xy;
		}
		if (damping + tex_damping > 0.0) {
			float v = length(VELOCITY);
			float damp = (damping + tex_damping) * mix(1.0, rand_from_seed(alt_seed), damping_random);
			v -= damp * DELTA;
			if (v < 0.0) {
				VELOCITY = vec3(0.0);
			} else {
				VELOCITY = normalize(VELOCITY) * v;
			}
		}
		float base_angle = (initial_angle + tex_angle) * mix(1.0, angle_rand, initial_angle_random);
		base_angle += CUSTOM.y * LIFETIME * (angular_velocity + tex_angular_velocity) * mix(1.0, rand_from_seed(alt_seed) * 2.0 - 1.0, angular_velocity_random);
		CUSTOM.x = base_angle * degree_to_rad;
		CUSTOM.z = (anim_offset + tex_anim_offset) * mix(1.0, anim_offset_rand, anim_offset_random) + CUSTOM.y * (anim_speed + tex_anim_speed) * mix(1.0, rand_from_seed(alt_seed), anim_speed_random);
	}
	float tex_scale = 1.0;
	float tex_hue_variation = 0.0;
//// this part is commented out because it overwrites the particle color
//  float hue_rot_angle = (hue_variation + tex_hue_variation) * pi * 2.0 * mix(1.0, hue_rot_rand * 2.0 - 1.0, hue_variation_random);
//  float hue_rot_c = cos(hue_rot_angle);
//  float hue_rot_s = sin(hue_rot_angle);
//  mat4 hue_rot_mat = mat4(vec4(0.299, 0.587, 0.114, 0.0),
//      vec4(0.299, 0.587, 0.114, 0.0),
//      vec4(0.299, 0.587, 0.114, 0.0),
//      vec4(0.000, 0.000, 0.000, 1.0)) +
//    mat4(vec4(0.701, -0.587, -0.114, 0.0),
//      vec4(-0.299, 0.413, -0.114, 0.0),
//      vec4(-0.300, -0.588, 0.886, 0.0),
//      vec4(0.000, 0.000, 0.000, 0.0)) * hue_rot_c +
//    mat4(vec4(0.168, 0.330, -0.497, 0.0),
//      vec4(-0.328, 0.035,  0.292, 0.0),
//      vec4(1.250, -1.050, -0.203, 0.0),
//      vec4(0.000, 0.000, 0.000, 0.0)) * hue_rot_s;
//  COLOR = hue_rot_mat * color_value;

	TRANSFORM[0] = vec4(cos(CUSTOM.x), -sin(CUSTOM.x), 0.0, 0.0);
	TRANSFORM[1] = vec4(sin(CUSTOM.x), cos(CUSTOM.x), 0.0, 0.0);
	TRANSFORM[2] = vec4(0.0, 0.0, 1.0, 0.0);
	float base_scale = tex_scale * mix(scale, 1.0, scale_random * scale_rand);
	if (base_scale < 0.000001) {
		base_scale = 0.000001;
	}
	TRANSFORM[0].xyz *= base_scale;
	TRANSFORM[1].xyz *= base_scale;
	TRANSFORM[2].xyz *= base_scale;
	VELOCITY.z = 0.0;

	// Explosion code, fades out the particles
	COLOR.rgb = sprite_color.rgb;
	if ((CUSTOM.y * LIFETIME) > fade_delay) {
		COLOR.a = clamp(COLOR.a - (1.0 / (LIFETIME - fade_delay) * DELTA), 0.0, COLOR.a);
	}

	TRANSFORM[3].z = 0.0;
	if (CUSTOM.y > CUSTOM.w) {
		ACTIVE = false;
	}
}
