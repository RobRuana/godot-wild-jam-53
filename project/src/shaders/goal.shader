shader_type canvas_item;


uniform float border_width : hint_range(0.0001, 1.0) = 0.3;

const float PI = 3.14159265359;
const float HALF_PI = 1.57079632679;
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
	}
	COLOR = vec4(tex.rgb, alpha);
}
