shader_type canvas_item;

uniform float chromatic_aberration : hint_range(0.0, 5.0) = 0.0;
uniform float vignette_intensity : hint_range(0.0, 1.0) = 0.0;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

void fragment() {
    vec2 uv = SCREEN_UV;
    vec2 center = vec2(0.5, 0.5);
    
    // Chromatic aberration
    float r = texture(SCREEN_TEXTURE, uv + vec2(chromatic_aberration * 0.01, 0.0)).r;
    float g = texture(SCREEN_TEXTURE, uv).g;
    float b = texture(SCREEN_TEXTURE, uv - vec2(chromatic_aberration * 0.01, 0.0)).b;
    
    // Vignette
    float dist = length(uv - center);
    float vignette = smoothstep(0.8, 0.2, dist * (1.0 + vignette_intensity));
    
    COLOR = vec4(r, g, b, 1.0) * vignette;
}