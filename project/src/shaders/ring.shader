shader_type canvas_item;

const float PI = 3.14159265359;
const float HALF_PI = 1.57079632679;
const float TWO_PI = 6.2831853072;


uniform float border_width: hint_range(0.0001, 1.0) = 0.2;
uniform float gap_width: hint_range(0.0, 6.2831853072) = 0.2;
uniform float gap_modulo: hint_range(0.0001, 6.2831853072) = 1.57079632679;
uniform float rotation_scale = 1.0;


float ease_in_out(float n) { return 0.5 + (sin((clamp(n, 0.0, 1.0) - 0.5) * PI) * 0.5); }
float ease_in_out_mix(float f1, float f2, float n) { return mix(f1, f2, ease_in_out(n)); }
float ease_in(float n) { return 1.0 + sin((clamp(n, 0.0, 1.0) - 1.0) * HALF_PI); }
float ease_in_mix(float f1, float f2, float n) { return mix(f1, f2, ease_in(n)); }
float ease_out(float n) { return sin(clamp(n, 0.0, 1.0) * HALF_PI); }
float ease_out_mix(float f1, float f2, float n) { return mix(f1, f2, ease_out(n)); }

void fragment() {
	vec4 tex = texture(TEXTURE, UV);
	vec2 center_uv = ((UV) - vec2(0.5, 0.5)) * 2.0;
	float d = length(center_uv);
	float alpha = 1.0;
	if (d > 1.0 || d < 1.0 - border_width) {
		alpha = 0.0;
	} else {
		float angle = mod(atan(center_uv.y, center_uv.x) + (TIME * rotation_scale), gap_modulo);
		if (angle > gap_modulo - (gap_width * 0.5) || angle < (gap_width * 0.5)) {
			alpha = 0.0;
		}
	}
	COLOR = vec4(tex.rgb, alpha);
}
