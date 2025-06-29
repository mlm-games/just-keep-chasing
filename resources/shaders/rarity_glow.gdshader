shader_type canvas_item;

uniform vec4 glow_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float pulse_speed: hint_range(0.0, 5.0) = 2.0;
uniform float pulse_intensity: hint_range(0.0, 0.5) = 0.3;

void fragment() {
    vec4 texture_color = texture(TEXTURE, UV);

    // Create a soft inner glow mask from the alpha channel
    float glow_mask = smoothstep(0.0, 1.0, texture_color.a);

    // Create a pulsing effect
    float pulse = sin(TIME * pulse_speed) * 0.5 + 0.5; // Oscillates between 0 and 1
    float pulse_glow = pulse * pulse_intensity;

    // Mix the glow color with the texture color
    vec3 final_rgb = mix(texture_color.rgb, glow_color.rgb, glow_mask * pulse_glow);

    COLOR = vec4(final_rgb, texture_color.a);
}
