shader_type canvas_item;

// Soft shadows and depth
uniform bool enable_shadow = true;
uniform vec2 shadow_offset = vec2(3.0, 3.0);
uniform vec4 shadow_color : source_color = vec4(0.0, 0.0, 0.0, 0.3);
uniform float shadow_blur : hint_range(0.0, 10.0) = 2.0;

// Outline for definition
uniform bool enable_outline = true;
uniform float outline_width : hint_range(0.0, 10.0) = 1.5;
uniform vec4 outline_color : source_color = vec4(0.1, 0.1, 0.1, 1.0);

// Inner glow/rim light
uniform bool enable_inner_glow = true;
uniform float inner_glow_width : hint_range(0.0, 20.0) = 3.0;
uniform vec4 inner_glow_color : source_color = vec4(1.0, 1.0, 1.0, 0.15);

// Gradient overlay
uniform bool enable_gradient = true;
uniform vec4 gradient_top : source_color = vec4(1.0, 1.0, 1.0, 0.1);
uniform vec4 gradient_bottom : source_color = vec4(0.0, 0.0, 0.0, 0.2);

// Subtle noise texture
uniform bool enable_texture = true;
uniform float texture_scale : hint_range(0.1, 5.0) = 1.0;
uniform float texture_strength : hint_range(0.0, 0.5) = 0.05;

// Color enhancement
uniform float saturation : hint_range(0.0, 2.0) = 1.1;
uniform float brightness : hint_range(-0.5, 0.5) = 0.05;
uniform float contrast : hint_range(0.5, 2.0) = 1.1;

// Smooth anti-aliasing
uniform float smoothing : hint_range(0.0, 2.0) = 0.5;

float random(vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

float noise(vec2 st) {
    vec2 i = floor(st);
    vec2 f = fract(st);
    float a = random(i);
    float b = random(i + vec2(1.0, 0.0));
    float c = random(i + vec2(0.0, 1.0));
    float d = random(i + vec2(1.0, 1.0));
    vec2 u = f * f * (3.0 - 2.0 * f);
    return mix(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}

vec3 rgb_to_hsv(vec3 c) {
    vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
    vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));
    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

vec3 hsv_to_rgb(vec3 c) {
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

float get_alpha_with_smoothing(sampler2D tex, vec2 uv, float width) {
    vec2 tex_size = vec2(textureSize(tex, 0));
    float alpha = texture(tex, uv).a;

    if (width > 0.0) {
        for (float x = -width; x <= width; x += 1.0) {
            for (float y = -width; y <= width; y += 1.0) {
                vec2 offset = vec2(x, y) / tex_size;
                alpha = max(alpha, texture(tex, uv + offset).a);
            }
        }
    }

    return smoothstep(0.4 - smoothing * 0.1, 0.6 + smoothing * 0.1, alpha);
}

void fragment() {
    vec2 uv = UV;
    vec4 original_color = texture(TEXTURE, uv);

    // Get smooth alpha for anti-aliasing
    float smooth_alpha = get_alpha_with_smoothing(TEXTURE, uv, smoothing);

    // Shadow layer
    vec4 shadow = vec4(0.0);
    if (enable_shadow && original_color.a < 0.5) {
        vec2 shadow_uv = uv - shadow_offset / vec2(textureSize(TEXTURE, 0));
        float shadow_alpha = 0.0;

        // Blur the shadow
        float blur_samples = max(1.0, shadow_blur);
        for (float i = -blur_samples; i <= blur_samples; i += 1.0) {
            for (float j = -blur_samples; j <= blur_samples; j += 1.0) {
                vec2 offset = vec2(i, j) / vec2(textureSize(TEXTURE, 0));
                shadow_alpha = max(shadow_alpha, texture(TEXTURE, shadow_uv + offset).a);
            }
        }
        shadow = vec4(shadow_color.rgb, shadow_color.a * shadow_alpha);
    }

    // Main color with enhancements
    vec3 color = original_color.rgb;

    // Apply color adjustments
    color = (color - 0.5) * contrast + 0.5 + brightness;
    vec3 hsv = rgb_to_hsv(color);
    hsv.y *= saturation;
    color = hsv_to_rgb(hsv);

    // Add gradient overlay
    if (enable_gradient && original_color.a > 0.5) {
        float gradient_factor = 1.0 - uv.y;
        vec4 gradient = mix(gradient_bottom, gradient_top, gradient_factor);
        color = mix(color, gradient.rgb, gradient.a);
    }

    // Add subtle texture
    if (enable_texture && original_color.a > 0.5) {
        float n = noise(uv * texture_scale * 100.0);
        color = mix(color, color * (1.0 + n), texture_strength);
    }

    // Outline
    vec4 outline = vec4(0.0);
    if (enable_outline && original_color.a < 0.5) {
        float outline_alpha = 0.0;
        float width = outline_width;

        for (float angle = 0.0; angle < 6.28; angle += 0.785) {
            vec2 offset = vec2(cos(angle), sin(angle)) * width / vec2(textureSize(TEXTURE, 0));
            outline_alpha = max(outline_alpha, texture(TEXTURE, uv + offset).a);
        }

        outline = vec4(outline_color.rgb, outline_color.a * outline_alpha);
    }

    // Inner glow
    vec4 inner_glow = vec4(0.0);
    if (enable_inner_glow && original_color.a > 0.5) {
        float edge_distance = 1.0;
        float samples = inner_glow_width;

        for (float angle = 0.0; angle < 6.28; angle += 0.785) {
            for (float dist = 1.0; dist <= samples; dist += 1.0) {
                vec2 offset = vec2(cos(angle), sin(angle)) * dist / vec2(textureSize(TEXTURE, 0));
                float sample_alpha = texture(TEXTURE, uv + offset).a;
                if (sample_alpha < 0.5) {
                    edge_distance = min(edge_distance, dist / samples);
                }
            }
        }

        float glow_strength = 1.0 - edge_distance;
        inner_glow = vec4(inner_glow_color.rgb, inner_glow_color.a * glow_strength);
    }

    // Composite layers
    vec4 final_color = shadow;
    final_color = mix(final_color, outline, outline.a);
    final_color = mix(final_color, vec4(color, smooth_alpha), smooth_alpha);
    final_color = mix(final_color, inner_glow, inner_glow.a * smooth_alpha);

    COLOR = final_color;
}
