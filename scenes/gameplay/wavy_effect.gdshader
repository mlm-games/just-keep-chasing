shader_type canvas_item;

uniform float amplitude = 0.02;
uniform float frequency = 3.0;
uniform float speed = 2.0;
uniform vec4 modulate_color = vec4(1.0, 1.0, 1.0, 1.0);

void fragment() {
    vec2 uv = UV;
    uv.x += sin(uv.y * frequency + TIME * speed) * amplitude;
    COLOR = texture(TEXTURE, uv) * modulate_color;
}