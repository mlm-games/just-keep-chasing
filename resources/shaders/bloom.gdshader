shader_type canvas_item;

uniform float threshold: hint_range(0.0, 1.0) = 0.5; // Brightness threshold for bloom
uniform float intensity: hint_range(0.0, 2.0) = 1.0; // Overall bloom strength
uniform float blur_scale: hint_range(0.5, 4.0) = 1.0; // Size of bloom effect
uniform vec4 bloom_color: source_color = vec4(1.0);
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

// Gaussian weight calculation
float gaussian(float x, float sigma) {
    return (1.0 / (sqrt(2.0 * 3.14159) * sigma)) * exp(-((x * x) / (2.0 * sigma * sigma)));
}

vec4 sample_glow_pixel(sampler2D tex, vec2 uv, float lod) {
    vec4 color = textureLod(tex, uv, lod);
    float brightness = max(max(color.r, color.g), color.b);
    return max(color * smoothstep(threshold - 0.1, threshold + 0.1, brightness) - threshold, vec4(0.0));
}

void fragment() {
    vec2 ps = SCREEN_PIXEL_SIZE * blur_scale;

    // Multi-sample blur with gaussian weights
    vec4 blur_sum = vec4(0.0);
    float weight_sum = 0.0;

    // Sample 13 points
    for(float x = -6.0; x <= 6.0; x++) {
        float weight = gaussian(x, 3.0);
        vec2 offset = vec2(x * ps.x, 0.0);
        blur_sum += sample_glow_pixel(SCREEN_TEXTURE, SCREEN_UV + offset, 2.0) * weight;
        weight_sum += weight;
    }

    vec4 horizontal_blur = blur_sum / weight_sum;
    blur_sum = vec4(0.0);
    weight_sum = 0.0;

    // Vertical blur pass
    for(float y = -6.0; y <= 6.0; y++) {
        float weight = gaussian(y, 3.0);
        vec2 offset = vec2(0.0, y * ps.y);
        blur_sum += sample_glow_pixel(SCREEN_TEXTURE, SCREEN_UV + offset, 2.0) * weight;
        weight_sum += weight;
    }

    vec4 vertical_blur = blur_sum / weight_sum;

    // Combine horizontal and vertical blur
    vec4 glowing_col = (horizontal_blur + vertical_blur) * 0.5;

    // Get original color
    vec4 original = texture(SCREEN_TEXTURE, SCREEN_UV);

    // Blend bloom with original color
    COLOR = original + (glowing_col * bloom_color * intensity);
}