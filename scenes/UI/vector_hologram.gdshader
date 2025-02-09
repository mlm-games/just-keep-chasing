shader_type canvas_item;

uniform vec4 primary_color : source_color = vec4(0.0, 0.6, 1.0, 1.0);
uniform vec4 secondary_color : source_color = vec4(0.0, 0.2, 0.5, 1.0);
uniform vec4 accent_color : source_color = vec4(1.0, 1.0, 1.0, 0.5);
uniform float line_thickness : hint_range(0.0, 0.1) = 0.003;
uniform float animation_speed : hint_range(0.1, 2.0) = 1.0;
uniform float pattern_scale : hint_range(1.0, 10.0) = 3.0;

float geometric_pattern(vec2 uv) {
    // Create hexagonal grid
    vec2 grid = uv * pattern_scale;
    grid.x *= 1.15;
    grid.y += mod(floor(grid.x), 2.0) * 0.5;

    vec2 grid_id = floor(grid);
    vec2 local_pos = fract(grid) - 0.5;

    // Smooth hexagon shape
    float hex = length(max(abs(local_pos) * 1.5, local_pos));
    return smoothstep(0.5, 0.48, hex);
}

float animate_lines(vec2 uv, float time) {
    float line = sin(uv.y * 10.0 + uv.x * 5.0 + time * 2.0);
    return smoothstep(0.9, 1.0, line);
}

void fragment() {
    vec2 uv = UV;
    float time = TIME * animation_speed;

    // Create base gradient
    vec4 gradient = mix(primary_color, secondary_color, uv.y);

    // Add geometric pattern
    float pattern = geometric_pattern(uv);

    // Animated lines
    float lines = animate_lines(uv, time);

    // Edge highlight
    float edge = 1.0 - distance(uv, vec2(0.5));
    edge = smoothstep(0.0, 0.5, edge);

    // Combine effects
    vec4 final_color = gradient;
    final_color = mix(final_color, accent_color, pattern * 0.3);
    final_color += accent_color * lines * 0.1;
    final_color += accent_color * edge * 0.2;

    // Add subtle pulsing
    float pulse = sin(time) * 0.1 + 0.9;
    final_color *= pulse;

    // Clean lines at specific positions
    float horizontal_lines = step(1.0 - line_thickness, fract(uv.y * 8.0));
    float vertical_lines = step(1.0 - line_thickness, fract(uv.x * 15.0));
    final_color += accent_color * (horizontal_lines + vertical_lines) * 0.1;

    COLOR = final_color;
}