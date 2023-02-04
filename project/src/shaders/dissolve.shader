/*
Shader from Godot Shaders - the free shader library.
godotshaders.com/shader/teleport-effect

This shader is under CC0 license. Feel free to use, improve and 
change this shader according to your needs and consider sharing 
the modified result on godotshaders.com.
*/

shader_type canvas_item;

uniform float progress : hint_range(0.0, 1.0);
uniform float noise_density = 512;
uniform vec4 color : hint_color = vec4(0.5, 0.5, 0.5, 1.0);

// We are generating our own noise here. You could experiment with the 
// built in SimplexNoise or your own noise texture for other effects.
vec2 random(vec2 uv){
	uv = vec2(dot(uv, vec2(127.1, 311.7)), dot(uv, vec2(269.5, 183.3)));
	return -1.0 + 2.0 * fract(sin(uv) * 43758.5453123);
}

float noise(vec2 uv) {
	vec2 uv_index = floor(uv);
	vec2 uv_fract = fract(uv);

	vec2 blur = smoothstep(0.0, 1.0, uv_fract);

	return mix( mix( dot( random(uv_index + vec2(0.0,0.0) ), uv_fract - vec2(0.0,0.0) ),
					 dot( random(uv_index + vec2(1.0,0.0) ), uv_fract - vec2(1.0,0.0) ), blur.x),
				mix( dot( random(uv_index + vec2(0.0,1.0) ), uv_fract - vec2(0.0,1.0) ),
					 dot( random(uv_index + vec2(1.0,1.0) ), uv_fract - vec2(1.0,1.0) ), blur.x), blur.y) * 0.5 + 0.5;
}

const float PI = 3.14159265359;
const float HALF_PI = 1.57079632679;
float ease_in_out(float n) { return 0.5 + (sin((clamp(n, 0.0, 1.0) - 0.5) * PI) * 0.5); }
float ease_in_out_mix(float f1, float f2, float n) { return mix(f1, f2, ease_in_out(n)); }
float ease_in(float n) { return 1.0 + sin((clamp(n, 0.0, 1.0) - 1.0) * HALF_PI); }
float ease_in_mix(float f1, float f2, float n) { return mix(f1, f2, ease_in(n)); }
float ease_out(float n) { return sin(clamp(n, 0.0, 1.0) * HALF_PI); }
float ease_out_mix(float f1, float f2, float n) { return mix(f1, f2, ease_out(n)); }

void fragment()
{
	vec4 tex = texture(TEXTURE, UV) * MODULATE;
	vec2 aspect = vec2(1.0, TEXTURE_PIXEL_SIZE.x / TEXTURE_PIXEL_SIZE.y);
	
	float noise = noise(UV * noise_density * aspect) * UV.y;
	
	float d1 = step(progress, noise);

	float lower = ease_out(progress);
	float upper = ease_out(progress * 2.0);
	tex.rgb = mix(tex.rgb, color.rgb, clamp(ease_in_out((upper - UV.y) / (upper - lower)), 0.0, 1.0));
	tex.a *= d1;
	
	COLOR = tex;
}
