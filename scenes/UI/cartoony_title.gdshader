shader_type canvas_item;

uniform float bounce_height : hint_range(0.0, 1.0) = 0.0;
uniform float squash : hint_range(0.5, 1.5) = 1.0;
uniform float rotation : hint_range(-0.2, 0.2) = 0.0;

void vertex() {
    // Apply bounce height
    VERTEX.y -= bounce_height * 50.0;

    // Apply squash and stretch
    VERTEX.y *= squash;
    VERTEX.x /= squash;

    // Apply rotation
    float cos_rot = cos(rotation);
    float sin_rot = sin(rotation);
    vec2 rotated = vec2(
        VERTEX.x * cos_rot - VERTEX.y * sin_rot,
        VERTEX.x * sin_rot + VERTEX.y * cos_rot
    );
    VERTEX = rotated;
}
