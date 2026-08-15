shader_type spatial;
render_mode blend_add, cull_front, depth_draw_never, unshaded;

uniform vec3 atmosphere_color : source_color = vec3(0.20, 0.76, 1.0);
uniform float density : hint_range(0.0, 3.0) = 1.0;
uniform float falloff : hint_range(1.0, 12.0) = 4.2;

void fragment() {
    float fresnel = pow(1.0 - clamp(dot(normalize(NORMAL), normalize(VIEW)), 0.0, 1.0), falloff);
    float inner = pow(fresnel, 3.0);
    ALBEDO = atmosphere_color;
    EMISSION = atmosphere_color * (0.55 + inner * 1.2);
    ALPHA = clamp(fresnel * density, 0.0, 0.82);
}
