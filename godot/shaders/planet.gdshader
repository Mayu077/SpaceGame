shader_type spatial;
render_mode cull_back, depth_draw_opaque, diffuse_burley, specular_schlick_ggx;

uniform vec3 abyss_color : source_color = vec3(0.027, 0.075, 0.106);
uniform vec3 lowland_color : source_color = vec3(0.125, 0.353, 0.388);
uniform vec3 highland_color : source_color = vec3(0.694, 0.659, 0.459);
uniform vec3 peak_color : source_color = vec3(0.83, 0.80, 0.69);
uniform vec3 water_color : source_color = vec3(0.025, 0.16, 0.23);
uniform float seed = 5.4;
uniform float sea_level : hint_range(0.2, 0.8) = 0.51;
uniform float roughness_land : hint_range(0.0, 1.0) = 0.78;
uniform float city_strength : hint_range(0.0, 4.0) = 1.35;

varying vec3 object_position;
varying vec3 world_normal;

float hash31(vec3 p) {
    p = fract(p * 0.1031);
    p += dot(p, p.yzx + 33.33);
    return fract((p.x + p.y) * p.z);
}

float noise3(vec3 p) {
    vec3 i = floor(p);
    vec3 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    return mix(
        mix(mix(hash31(i), hash31(i + vec3(1,0,0)), f.x),
            mix(hash31(i + vec3(0,1,0)), hash31(i + vec3(1,1,0)), f.x), f.y),
        mix(mix(hash31(i + vec3(0,0,1)), hash31(i + vec3(1,0,1)), f.x),
            mix(hash31(i + vec3(0,1,1)), hash31(i + vec3(1,1,1)), f.x), f.y), f.z);
}

float fbm(vec3 p) {
    float value = 0.0;
    float amplitude = 0.5;
    mat3 rotation = mat3(vec3(0.00,0.80,0.60), vec3(-0.80,0.36,-0.48), vec3(-0.60,-0.48,0.64));
    for (int octave = 0; octave < 7; octave++) {
        value += noise3(p) * amplitude;
        p = rotation * p * 2.03 + vec3(11.7);
        amplitude *= 0.5;
    }
    return value;
}

void vertex() {
    object_position = VERTEX;
    world_normal = NORMAL;
    vec3 direction = normalize(VERTEX);
    float continents = fbm(direction * 2.75 + vec3(seed));
    float mountains = fbm(direction * 17.0 + vec3(seed * 2.3));
    float displacement = max(0.0, continents - sea_level) * (0.012 + mountains * 0.012);
    VERTEX += direction * displacement;
}

void fragment() {
    vec3 direction = normalize(object_position);
    float continent = fbm(direction * 2.75 + vec3(seed));
    float broad = fbm(direction * 7.2 + vec3(seed * 1.7));
    float detail = fbm(direction * 31.0 + vec3(seed * 3.1));
    float land = smoothstep(sea_level - 0.018, sea_level + 0.032, continent);
    float mountain = smoothstep(0.56, 0.79, broad * 0.55 + continent * 0.5);
    float rock = smoothstep(0.57, 0.8, detail * 0.35 + broad * 0.7);
    float polar = smoothstep(0.72, 0.94, abs(direction.y) + fbm(direction * 9.0) * 0.13);

    vec3 terrain = mix(lowland_color, highland_color, mountain);
    terrain = mix(terrain, peak_color, rock * mountain * 0.72);
    terrain = mix(terrain, vec3(0.82, 0.9, 0.91), polar * 0.82);
    vec3 ocean = mix(abyss_color, water_color, smoothstep(0.22, sea_level, continent));
    ALBEDO = mix(ocean, terrain, land);
    METALLIC = 0.0;
    ROUGHNESS = mix(0.17, roughness_land, land);
    SPECULAR = mix(0.92, 0.28, land);

    // Tiny inhabited clusters remain visible on the dark hemisphere.
    float settlement = step(0.858, noise3(direction * 115.0 + vec3(seed * 9.0))) * land;
    EMISSION = vec3(1.0, 0.38, 0.09) * settlement * city_strength;
}
