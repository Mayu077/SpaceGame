class_name PlanetBody
extends Node3D

var body_name: String = "Unknown World"
var radius: float = 40.0
var scan_description: String = "Uncatalogued planetary body."
var scanned := false
var surface_mesh: MeshInstance3D
var atmosphere_mesh: MeshInstance3D
var cloud_mesh: MeshInstance3D
var spin_rate := 0.004

func configure(spec: Dictionary) -> PlanetBody:
    body_name = spec.get("name", "Unknown World")
    radius = spec.get("radius", 40.0)
    position = spec.get("position", Vector3.ZERO)
    spin_rate = spec.get("spin", 0.004)
    scan_description = spec.get("description", "Uncatalogued planetary body.")
    _build_surface(spec)
    if spec.get("atmosphere", true):
        _build_clouds(spec)
        _build_atmosphere(spec)
    if spec.get("rings", false):
        _build_rings(spec)
    return self

func _build_surface(spec: Dictionary) -> void:
    surface_mesh = MeshInstance3D.new()
    surface_mesh.name = "ProceduralSurface"
    var sphere := SphereMesh.new()
    sphere.radius = radius
    sphere.height = radius * 2.0
    sphere.radial_segments = 192
    sphere.rings = 128
    surface_mesh.mesh = sphere
    var material := ShaderMaterial.new()
    material.shader = load("res://godot/shaders/planet.gdshader")
    var palette: Dictionary = spec.get("palette", {})
    material.set_shader_parameter("abyss_color", palette.get("abyss", Color("07131b")))
    material.set_shader_parameter("lowland_color", palette.get("lowland", Color("205a63")))
    material.set_shader_parameter("highland_color", palette.get("highland", Color("b1a875")))
    material.set_shader_parameter("peak_color", palette.get("peak", Color("d4ccb0")))
    material.set_shader_parameter("water_color", palette.get("water", Color("0b3342")))
    material.set_shader_parameter("seed", spec.get("seed", 5.4))
    material.set_shader_parameter("sea_level", spec.get("sea", 0.51))
    material.set_shader_parameter("city_strength", spec.get("cities", 0.0))
    surface_mesh.material_override = material
    add_child(surface_mesh)

func _build_clouds(spec: Dictionary) -> void:
    cloud_mesh = MeshInstance3D.new()
    cloud_mesh.name = "VolumetricCloudShell"
    var sphere := SphereMesh.new()
    sphere.radius = radius * 1.018
    sphere.height = radius * 2.036
    sphere.radial_segments = 160
    sphere.rings = 96
    cloud_mesh.mesh = sphere
    var material := ShaderMaterial.new()
    material.shader = load("res://godot/shaders/clouds.gdshader")
    material.set_shader_parameter("seed", spec.get("seed", 5.4))
    material.set_shader_parameter("coverage", spec.get("cloud_coverage", 0.54))
    cloud_mesh.material_override = material
    add_child(cloud_mesh)

func _build_atmosphere(spec: Dictionary) -> void:
    atmosphere_mesh = MeshInstance3D.new()
    atmosphere_mesh.name = "RayleighAtmosphere"
    var sphere := SphereMesh.new()
    sphere.radius = radius * 1.052
    sphere.height = radius * 2.104
    sphere.radial_segments = 160
    sphere.rings = 96
    atmosphere_mesh.mesh = sphere
    var material := ShaderMaterial.new()
    material.shader = load("res://godot/shaders/atmosphere.gdshader")
    material.set_shader_parameter("atmosphere_color", spec.get("atmosphere_color", Color("45d9ff")))
    material.set_shader_parameter("density", spec.get("atmosphere_density", 1.0))
    atmosphere_mesh.material_override = material
    add_child(atmosphere_mesh)

func _build_rings(spec: Dictionary) -> void:
    var rings := MeshInstance3D.new()
    rings.name = "RingSystem"
    var quad := QuadMesh.new()
    quad.size = Vector2(radius * 6.6, radius * 6.6)
    quad.orientation = PlaneMesh.FACE_Y
    rings.mesh = quad
    var shader := Shader.new()
    shader.code = """shader_type spatial;
render_mode blend_mix,cull_disabled,depth_draw_alpha_prepass;
uniform vec3 ring_color:source_color=vec3(.78,.59,.46);
float h(float n){return fract(sin(n*519.23)*43758.5);}
void fragment(){vec2 q=UV-.5;float r=length(q)*2.0;float inr=smoothstep(.36,.39,r);float out=1.0-smoothstep(.92,.97,r);float bands=.22+.72*h(floor(r*170.0));float gaps=smoothstep(.018,.032,abs(r-.58))*smoothstep(.009,.022,abs(r-.74));ALBEDO=ring_color*(.62+bands*.46);METALLIC=.05;ROUGHNESS=.8;ALPHA=inr*out*gaps*(.18+bands*.58);}"""
    var material := ShaderMaterial.new()
    material.shader = shader
    material.set_shader_parameter("ring_color", spec.get("ring_color", Color("c99678")))
    rings.material_override = material
    rings.rotation.z = spec.get("ring_tilt", 0.18)
    add_child(rings)

func _process(delta: float) -> void:
    surface_mesh.rotate_y(spin_rate * delta)
    if cloud_mesh:
        cloud_mesh.rotate_y(spin_rate * delta * 1.16)

func distance_to_surface(point: Vector3) -> float:
    return global_position.distance_to(point) - radius
