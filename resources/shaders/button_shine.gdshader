shader_type canvas_item;

uniform sampler2D shine_gradient;
uniform float shine_speed = 1.0;

void fragment() {
    float shine_pos = mod(TIME * shine_speed - UV.x - UV.y, 3.0);
    float shine_value = texture(shine_gradient, vec2(shine_pos, 0.0)).r;
    COLOR = vec4(1.0, 1.0, 1.0, shine_value);
}