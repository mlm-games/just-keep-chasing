shader_type canvas_item;

// Animation control uniforms
uniform float vibrate_intensity: hint_range(0.0, 1.0) = 0.0;
uniform float frequency: hint_range(1.0, 100.0) = 60.0;
uniform float drift_speed: hint_range(0.1, 5.0) = 2.5;
uniform float jiggle_speed: hint_range(1.0, 20.0) = 10.0;
uniform float wave_amplitude: hint_range(0.1, 2.0) = 1.0;

// Additional customization uniforms
uniform float edge_height: hint_range(0.0, 0.5) = 0.2;
uniform vec4 effect_color: source_color = vec4(1.0, 1.0, 1.0, 1.0);

float calculate_wave_effect(vec2 uv, float time) {
    // Separate wave components for better readability
    float vibrate_wave = sin(time * 1.0 + uv.x * 250.0) * vibrate_intensity;
    float drift_wave = sin(time * drift_speed + uv.x * frequency);
    float jiggle_wave = 0.5 * cos(-time * jiggle_speed + uv.x * 20.0);

    // Combine wave effects
    return vibrate_wave + drift_wave + jiggle_wave;
}

float calculate_height_threshold(float y_position) {
    return 1.0 - (2.0 / wave_amplitude) * (y_position / edge_height);
}

void fragment() {
    // Only process pixels within the edge height
    if (UV.y <= edge_height) {
        float height_threshold = calculate_height_threshold(UV.y);
        float wave = calculate_wave_effect(UV, TIME);

        // Calculate final alpha
        float alpha = wave > (1.5 + vibrate_intensity) * height_threshold ? 1.0 : 0.0;

        // Apply color and alpha
        COLOR = effect_color;
        COLOR.a *= alpha;
    } else {
        // Make pixels outside the edge height transparent
        COLOR.a = 0.0;
    }
}