shader_type canvas_item;

uniform float progress : hint_range(0.0, 1.0);

void fragment() {
    float dist = distance(UV, vec2(0.5));
    float circle = smoothstep(progress, progress - 0.1, dist);
    circle *= smoothstep(progress - 0.5, progress - 0.1, dist);
    COLOR = vec4(1.0, 1.0, 1.0, circle * 0.3 * (1.0 - progress));
}