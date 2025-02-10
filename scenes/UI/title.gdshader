shader_type canvas_item;

uniform vec4 text_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 highlight_color : source_color = vec4(0.0, 0.8, 1.0, 1.0);
uniform float line_width : hint_range(0.0, 0.1) = 0.005;
uniform float reveal_progress : hint_range(0.0, 1.0) = 0.0;
uniform float glitch_intensity : hint_range(0.0, 1.0) = 0.2;
uniform bool animate = true;

float random(vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898,78.233))) * 43758.5453123);
}

vec2 glitch(vec2 uv, float time) {
    vec2 glitched_uv = uv;

    if (animate) {
        float noise = random(vec2(time * 0.1, uv.y));
        float glitch_line = step(0.98, noise);
        float offset = (noise - 0.5) * 0.1 * glitch_intensity;

        glitched_uv.x += offset * glitch_line;
    }

    return glitched_uv;
}

float geometric_reveal(vec2 uv, float progress) {
    float diagonal = uv.x + uv.y;
    float reveal = step(diagonal, progress * 2.0);

    // Add clean lines following the reveal
    float lines = step(mod(diagonal * 10.0, 1.0), 0.5);
    float line_reveal = step(diagonal, (progress * 2.0) - 0.1);

    return reveal + lines * line_reveal * 0.2;
}

void fragment() {
    vec2 uv = UV;
    float time = TIME;

    // Apply glitch effect
    vec2 glitched_uv = glitch(uv, time);

    // Get the original texture color (assuming this is applied to text)
    vec4 original = texture(TEXTURE, glitched_uv);

    // Calculate reveal mask
    float reveal_mask = geometric_reveal(uv, reveal_progress);

    // Create scanning line effect
    float scan_line = smoothstep(0.0, line_width,
        abs(mod(glitched_uv.y * 20.0 + time * 2.0, 1.0) - 0.5));

    // Create edge highlight
    float edge = abs(original.a - texture(TEXTURE, glitched_uv + vec2(line_width, 0.0)).a) +
                 abs(original.a - texture(TEXTURE, glitched_uv - vec2(line_width, 0.0)).a);

    // Combine effects
    vec4 final_color = text_color;
    final_color = mix(final_color, highlight_color, edge);
    final_color.a = original.a * reveal_mask;

    // Add scan line effect
    final_color += highlight_color * scan_line * original.a * 0.2;

    // Add glowing edges
    float glow = edge * 2.0;
    final_color += highlight_color * glow * original.a;

    COLOR = final_color;
}