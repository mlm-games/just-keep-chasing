shader_type canvas_item;
uniform float ring_width : hint_range(0.0, 0.5) = 0.1;
uniform float feather : hint_range(0.0, 0.2) = 0.02;

void fragment() {
    float dist_from_center = distance(UV, vec2(0.5));

    float ring_centerline_radius = 0.5 - (ring_width / 2.0);

    float dist_from_ring = abs(dist_from_center - ring_centerline_radius);

    float ring_alpha = 1.0 - smoothstep(ring_width / 2.0 - feather, ring_width / 2.0 + feather, dist_from_ring);

    COLOR.a *= ring_alpha;
}
