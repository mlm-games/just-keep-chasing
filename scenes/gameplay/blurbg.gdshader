shader_type canvas_item;

uniform float blur_amount = 1.0;
uniform float speed_factor = 1.0;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

void fragment() {
    vec2 uv = SCREEN_UV;
    vec2 velocity = vec2(TIME * speed_factor, 0.0);
    COLOR = textureLod(SCREEN_TEXTURE, uv + velocity * blur_amount, 0.0);
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
