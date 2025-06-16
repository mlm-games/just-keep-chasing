shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform float strength : hint_range(0.0, 100.0) = 0.0;
uniform float quality : hint_range(0.0, 1.0) = 0.7; // Lower for performance

void fragment() {
	vec2 offset = vec2(strength / 1000.0 * (1.0 - quality), strength / 1000.0 * (1.0 - quality));
	float r = texture(SCREEN_TEXTURE, SCREEN_UV - offset).r;
	float g = texture(SCREEN_TEXTURE, SCREEN_UV).g;
	float b = texture(SCREEN_TEXTURE, SCREEN_UV + offset).b;
	COLOR = vec4(r, g, b, 1.0);
}
