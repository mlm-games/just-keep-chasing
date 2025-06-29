shader_type canvas_item;

uniform vec4 base_color : source_color = vec4(0.1, 0.6, 1.0, 1.0);
uniform vec4 glow_color : source_color = vec4(0.3, 0.8, 1.0, 1.0);
uniform float speed : hint_range(0.1, 5.0) = 1.0;
uniform float grid_size : hint_range(10.0, 100.0) = 40.0;
uniform float wave_intensity : hint_range(0.0, 2.0) = 1.0;

float random(vec2 pos) {
    return fract(sin(dot(pos.xy, vec2(12.9898,78.233))) * 43758.5453123);
}

float noise(vec2 pos) {
    vec2 i = floor(pos);
    vec2 f = fract(pos);

    float a = random(i);
    float b = random(i + vec2(1.0, 0.0));
    float c = random(i + vec2(0.0, 1.0));
    float d = random(i + vec2(1.0, 1.0));

    vec2 u = f * f * (3.0 - 2.0 * f);
    return mix(a, b, u.x) + (c - a)* u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}

void fragment() {
    // Create grid pattern
    vec2 scaled_uv = UV * grid_size;
    vec2 grid = abs(fract(scaled_uv - 0.5) - 0.5) / fwidth(scaled_uv);
    float grid_line = min(grid.x, grid.y);

    // Create moving waves
    float wave = sin(UV.y * 10.0 + TIME * speed) * wave_intensity;
    wave += sin(UV.x * 8.0 + TIME * speed * 0.7) * wave_intensity;

    // Add noise effect
    float noise_effect = noise(UV * 5.0 + TIME * 0.5);

    // Combine effects
    float line_alpha = 1.0 - min(grid_line, 1.0);
    float final_alpha = line_alpha + wave * 0.3 + noise_effect * 0.2;

    // Create pulsing effect
    float pulse = (sin(TIME * speed) + 1.0) * 0.5;

    // Final color
    vec4 final_color = mix(base_color, glow_color, pulse);
    final_color.a *= final_alpha;

    // Add scanning line effect
    float scan_line = step(0.99, fract(UV.y * 50.0 - TIME));
    final_color += vec4(1.0) * scan_line * 0.1;

    // Edge glow
    float edge_glow = 1.0 - distance(UV, vec2(0.5));
    final_color += glow_color * edge_glow * 0.2;

    COLOR = final_color;
}