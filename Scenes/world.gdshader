shader_type canvas_item;

uniform vec4 color_top = vec4(0.2, 0.6, 0.2, 1.0);    // Green
uniform vec4 color_bottom = vec4(0.1, 0.3, 0.5, 1.0); // Blue

void fragment() {
    float gradient = UV.y;
    COLOR = mix(color_top, color_bottom, gradient);
}