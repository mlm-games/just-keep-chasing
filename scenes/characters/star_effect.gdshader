shader_type canvas_item;

uniform float cycle_speed = 2.0;
uniform float brightness = 1.2;
uniform float saturation = 0.4;

void fragment() {
    vec4 texture_color = texture(TEXTURE, UV);

    // The rainbow effect (timed part)
    float hue = fract(TIME * cycle_speed);

    // Convert HSV to RGB
    vec3 rgb = vec3(0.0);
    float h = hue * 6.0;
    float i = floor(h);
    float f = h - i;
    float p = 1.0 - saturation;
    float q = 1.0 - saturation * f;
    float t = 1.0 - saturation * (1.0 - f);

    if (i == 0.0) rgb = vec3(1.0, t, p);
    else if (i == 1.0) rgb = vec3(q, 1.0, p);
    else if (i == 2.0) rgb = vec3(p, 1.0, t);
    else if (i == 3.0) rgb = vec3(p, q, 1.0);
    else if (i == 4.0) rgb = vec3(t, p, 1.0);
    else rgb = vec3(1.0, p, q);

    // Apply rainbow color only to non-transparent pixels
    vec4 rainbow = vec4(rgb * brightness, texture_color.a);
    COLOR = texture_color * rainbow;
}