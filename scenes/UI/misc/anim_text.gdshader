shader_type canvas_item;

uniform float effect_value : hint_range(0.0, 1.0);

void fragment() {
    vec4 text_color = texture(TEXTURE, UV);
    float glow = smoothstep(0.4, 0.5, text_color.a) * effect_value;
    COLOR = mix(text_color, vec4(1.0, 1.0, 1.0, text_color.a), glow * 0.5);
}