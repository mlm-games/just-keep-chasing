shader_type canvas_item;

uniform float explosion_progress : hint_range(0.0, 1.0) = 0.0;
uniform float noise_scale : hint_range(0.1, 10.0) = 3.0;
uniform float distortion_strength : hint_range(0.0, 1.0) = 0.3;
uniform float glow_intensity : hint_range(0.0, 5.0) = 2.0;
uniform float fade_power : hint_range(0.0, 4.0) = 2.0;
uniform sampler2D noise_texture;

// Color gradient matching your particle material
uniform vec4 color_hot : source_color = vec4(1.0, 1.0, 0.0, 1.0);
uniform vec4 color_mid : source_color = vec4(1.0, 0.188, 0.0, 1.0);
uniform vec4 color_cool : source_color = vec4(0.286, 0.247, 0.298, 1.0);

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

void fragment() {
    vec2 uv = UV - vec2(0.5);
    float dist = length(uv);
    
    // Create explosion ring
    float explosion_radius = explosion_progress * 0.5;
    float ring_width = 0.15 * (1.0 - explosion_progress * 0.5);
    float ring = 1.0 - smoothstep(explosion_radius - ring_width, explosion_radius, dist);
    ring *= smoothstep(explosion_radius, explosion_radius + ring_width, dist);
    
    vec2 noise_uv = uv * noise_scale + vec2(TIME * 0.1);
    float noise_value = noise(noise_uv);
    
    // Distort the ring with noise
    float distorted_dist = dist + (noise_value - 0.5) * distortion_strength * explosion_progress;
    float distorted_ring = 1.0 - smoothstep(explosion_radius - ring_width, explosion_radius, distorted_dist);
    distorted_ring *= smoothstep(explosion_radius, explosion_radius + ring_width, distorted_dist);
    
    // Create inner glow
    float inner_glow = 1.0 - smoothstep(0.0, explosion_radius * 1.5, dist);
    inner_glow *= (1.0 - explosion_progress);
    
    // Combine effects
    float explosion_shape = max(distorted_ring, inner_glow * 0.5);
    
    // Add hot spots
    float hot_spots = noise(uv * 8.0 + vec2(TIME * 0.5)) * explosion_shape;
    explosion_shape += hot_spots * 0.3;
    
    // Color gradient based on intensity
    vec4 color;
    if (explosion_shape > 0.7) {
        color = mix(color_mid, color_hot, (explosion_shape - 0.7) / 0.3);
    } else if (explosion_shape > 0.3) {
        color = mix(color_cool, color_mid, (explosion_shape - 0.3) / 0.4);
    } else {
        color = color_cool;
    }
    
    // Apply fade
    float fade = pow(1.0 - explosion_progress, fade_power);
    //explosion_shape *= fade;
    
    // Apply glow
    color.rgb *= glow_intensity;
    
    // Final alpha
    color.a *= explosion_shape;
    
    // Add some particle-like spots
    float particles = 0.0;
    for (int i = 0; i < 5; i++) {
        vec2 particle_pos = vec2(
            sin(float(i) * 1.234 + TIME * 2.0) * 0.3,
            cos(float(i) * 2.345 + TIME * 1.5) * 0.3
        );
        float particle_dist = length(uv - particle_pos * explosion_progress);
        particles += 1.0 - smoothstep(0.0, 0.05, particle_dist);
    }
    
    color.a = clamp(color.a + particles * fade * 0.5, 0.0, 1.0);
    
    COLOR = color;
}
