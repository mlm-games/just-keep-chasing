shader_type canvas_item;

uniform sampler2D edge_texture : repeat_enable;
uniform float closure;
uniform float uv_scale;
uniform vec4 modulation : source_color;
uniform float scroll_speed;

vec3 hsv2rgb(vec3 c) {
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

float spikePattern(float t, float period) {
    float spike = abs(fract(t/period) * 2.0 - 1.0);
    return pow(spike, 0.5);
}

float sharpEdgeEffect(float x, float y, float scale, float iTime) {
    float period = 0.05; // Smaller period for more spikes
    float amplitude = 0.1; // Increased amplitude for more pronounced spikes
    float border = mix(0.0, 0.3, abs(sin(iTime * 2.0))) + closure;

    // Sharp spiky pattern
    float spike = mix(0.0, 0.08, abs(sin(x * scale * 40.0 + iTime * 8.0)));
    float shift = iTime * 0.5; // Changed direction and speed

    float pattern = spikePattern(scale * (x - shift), 123);

    return step(1.0 - abs(y), scale * (pattern * amplitude + spike));
}

void fragment() {
    vec2 fragCoord = UV;
    vec2 iResolution = vec2(1.0, 1.0);
    float iTime = TIME * scroll_speed;

    vec2 uv = fragCoord/iResolution.xy * 2.0 - 1.0;
    float aspectRatio = 1080.0/1920.0;

    vec3 col = vec3(0);

    vec3 rainbow = hsv2rgb(vec3(iTime * 0.2, 1.0, 1.0));

    col = mix(col, rainbow, sharpEdgeEffect(uv.x, uv.y, 1.2, iTime));
    col = mix(col, rainbow, sharpEdgeEffect(-uv.y, uv.x, aspectRatio * 1.2, iTime));

    col = pow(max(col, 0.0), vec3(1.0/2.4));

    COLOR = vec4(col, length(col));
    COLOR = texture(edge_texture, vec2(UV.x - iTime/8.0, UV.y - iTime/8.0) * uv_scale) * modulation;
    COLOR.a = length(col);
}