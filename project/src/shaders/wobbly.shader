shader_type canvas_item;

uniform sampler2D displacement;
uniform float strength = 1.0;
uniform float time_scale = 1.0;
uniform float frames: hint_range(1.0, 60.0) = 4.0;


void fragment() {
	float c = TIME * time_scale;
	vec4 offset = texture(displacement, vec2(UV.x + c, UV.y + c)) * strength;
	COLOR = texture(TEXTURE, UV + offset.xy - vec2(0.5, 0.5) * strength);
}
