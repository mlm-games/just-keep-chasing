shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform float pixel_size : hint_range(1.0, 8.0, 1.0) = 3.0;
uniform float color_depth : hint_range(2.0, 32.0, 1.0) = 16.0;
uniform float contrast : hint_range(0.5, 2.0) = 1.2;
uniform float brightness : hint_range(-0.5, 0.5) = -0.05;
uniform float saturation : hint_range(0.0, 2.0) = 0.8;

// Edge detection for that crisp pixel art feel
uniform bool enhance_edges = true;
uniform float edge_threshold : hint_range(0.0, 1.0) = 0.15;
uniform float edge_darkness : hint_range(0.0, 1.0) = 0.3;

// Dithering for that retro feel
uniform bool use_dithering = true;
uniform float dither_size : hint_range(1.0, 4.0, 1.0) = 2.0;

// 4x4 Bayer matrix for better dithering
const mat4 bayer4x4 = mat4(
    vec4(0.0, 8.0, 2.0, 10.0),
    vec4(12.0, 4.0, 14.0, 6.0),
    vec4(3.0, 11.0, 1.0, 9.0),
    vec4(15.0, 7.0, 13.0, 5.0)
) / 16.0;

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

float get_edge_factor(sampler2D tex, vec2 uv, vec2 l_pixel_size) {
    vec2 offset = 1.0 / vec2(textureSize(tex, 0)) * l_pixel_size;
    
    // Sample surrounding pixels
    float tl = length(texture(tex, uv + vec2(-offset.x, -offset.y)).rgb);
    float tm = length(texture(tex, uv + vec2(0.0, -offset.y)).rgb);
    float tr = length(texture(tex, uv + vec2(offset.x, -offset.y)).rgb);
    float ml = length(texture(tex, uv + vec2(-offset.x, 0.0)).rgb);
    float mm = length(texture(tex, uv).rgb);
    float mr = length(texture(tex, uv + vec2(offset.x, 0.0)).rgb);
    float bl = length(texture(tex, uv + vec2(-offset.x, offset.y)).rgb);
    float bm = length(texture(tex, uv + vec2(0.0, offset.y)).rgb);
    float br = length(texture(tex, uv + vec2(offset.x, offset.y)).rgb);
    
    // Sobel edge detection
    float edge_x = (tl + 2.0 * ml + bl) - (tr + 2.0 * mr + br);
    float edge_y = (tl + 2.0 * tm + tr) - (bl + 2.0 * bm + br);
    
    return length(vec2(edge_x, edge_y));
}

void fragment() {
    vec2 screen_size = vec2(textureSize(SCREEN_TEXTURE, 0));
    vec2 screen_pos = SCREEN_UV * screen_size;
    
    // Pixelate coordinates
    vec2 pixelated_pos = floor(screen_pos / pixel_size) * pixel_size;
    vec2 pixelated_uv = pixelated_pos / screen_size;
    
    // Sample color
    vec4 color = texture(TEXTURE, pixelated_uv);
    
    // Apply contrast and brightness adjustments first
    vec3 adjusted = (color.rgb - 0.5) * contrast + 0.5 + brightness;
    adjusted = clamp(adjusted, 0.0, 1.0);
    
    // Adjust saturation
    vec3 hsv = rgb_to_hsv(adjusted);
    hsv.y *= saturation;
    adjusted = hsv_to_rgb(hsv);
    
    // Quantize colors
    vec3 quantized = floor(adjusted * color_depth + 0.5) / color_depth;
    
    // Apply dithering
    if (use_dithering) {
        vec2 dither_pos = mod(screen_pos / dither_size, 4.0);
        float dither_value = bayer4x4[int(dither_pos.x)][int(dither_pos.y)];
        
        // Apply dithering before quantization for smoother gradients
        vec3 dithered = adjusted + (dither_value - 0.5) / color_depth;
        quantized = floor(dithered * color_depth + 0.5) / color_depth;
    }
    
    // Edge enhancement
    if (enhance_edges && color.a > 0.1) {
        float edge = get_edge_factor(TEXTURE, pixelated_uv, vec2(pixel_size));
        if (edge > edge_threshold) {
            quantized *= 1.0 - (edge_darkness * smoothstep(edge_threshold, edge_threshold + 0.1, edge));
        }
    }
    
    COLOR = vec4(quantized, color.a);
}
