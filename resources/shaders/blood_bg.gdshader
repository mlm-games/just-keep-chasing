shader_type canvas_item;

// Tweak these in the editor!
group_uniforms Visuals;
uniform vec4 deep_color : source_color = vec4(0.5, 0.05, 0.1, 1.0);
uniform vec4 mid_color : source_color = vec4(1.0, 0.1, 0.2, 1.0);
uniform vec4 cell_color : source_color = vec4(1.0, 0.5, 0.3, 1.0);

group_uniforms Flow;
uniform float flow_speed : hint_range(0.0, 0.2) = 0.05;
uniform float noise_scale : hint_range(1.0, 10.0) = 4.0;
uniform float distortion_amount : hint_range(0.0, 0.05) = 0.01;

group_uniforms Cells;
uniform float cell_scale : hint_range(10.0, 50.0) = 25.0;
uniform float cell_density : hint_range(0.0, 1.0) = 0.15;
uniform float cell_speed_multiplier = 1.5;

group_uniforms Effects;
uniform float vignette_intensity : hint_range(0.0, 2.0) = 1.2;
uniform float vignette_smoothness : hint_range(0.1, 2.0) = 0.7;


//// Helper Functions for Procedural Noise
// 2D Hash function
vec2 random(vec2 p) {
    p = vec2(dot(p, vec2(127.1, 311.7)), dot(p, vec2(269.5, 183.3)));
    return -1.0 + 2.0 * fract(sin(p) * 43758.5453123);
}

// Value Noise function
float value_noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    f = f * f * (3.0 - 2.0 * f); // Smoothstep

    vec2 a = random(i);
    vec2 b = random(i + vec2(1.0, 0.0));
    vec2 c = random(i + vec2(0.0, 1.0));
    vec2 d = random(i + vec2(1.0, 1.0));

    return mix(mix(dot(a, f), dot(b, f - vec2(1.0, 0.0)), f.x),
               mix(dot(c, f - vec2(0.0, 1.0)), dot(d, f - vec2(1.0, 1.0)), f.x), f.y);
}


void fragment() {
    //// Distortion
    // Make the view wavy, like looking through liquid.
    vec2 distorted_uv = UV;
    distorted_uv.y += sin(distorted_uv.x * 8.0 + TIME) * distortion_amount;
    distorted_uv.x += cos(distorted_uv.y * 8.0 + TIME * 0.7) * distortion_amount;

    //// Background Flow
    // Two layers of noise moving in different directions for a liquid effect.
    vec2 motion = vec2(TIME * flow_speed, -TIME * flow_speed * 0.6);
    float noise1 = value_noise((distorted_uv + motion) * noise_scale);
    float noise2 = value_noise((distorted_uv - motion) * noise_scale * 1.5);
    float combined_noise = (noise1 + noise2) * 0.5;

    // Mix the two main blood colors based on the flow.
    vec3 base_color = mix(deep_color.rgb, mid_color.rgb, combined_noise);

    //// Floating Cells
    // A separate, faster, and smaller noise layer for the cell-like blobs.
    vec2 cell_motion = vec2(-TIME * flow_speed * cell_speed_multiplier, 0);
    float cell_noise = value_noise((distorted_uv + cell_motion) * cell_scale);

    // Use smoothstep to create hard-edged circles from the noise peaks.
    // 'cell_density' controls the cutoff point, determining how many cells appear.
    float cell_mask = smoothstep(1.0 - cell_density, 1.0 - (cell_density * 0.9), cell_noise);

    // Mix the cells on top of the base color.
    vec3 final_color = mix(base_color, cell_color.rgb, cell_mask);

    //// Vignette
    // Darken the corners to focus the player's view on the center.
    float dist_from_center = distance(UV, vec2(0.5));
    float vignette = smoothstep(vignette_smoothness, 0.2, dist_from_center);
    vignette = pow(vignette, vignette_intensity);

    // Apply vignette and set the final color
    COLOR.rgb = final_color * vignette;
}
