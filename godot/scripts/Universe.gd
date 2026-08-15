class_name NativeUniverse
extends Node3D

signal nearest_target_changed(target: Node3D)

var planets: Array[PlanetBody] = []
var resonators: Array[Node3D] = []
var current_system := 0
var nearest_target: Node3D
var star_light: DirectionalLight3D
var star_visual: MeshInstance3D
var asteroid_field: MultiMeshInstance3D
var rng := RandomNumberGenerator.new()

const SYSTEMS := [
    {"name":"Aster Reach","seed":20260725,"offset":Vector3.ZERO},
    {"name":"Veyra","seed":77331,"offset":Vector3(0,0,-4200)},
    {"name":"Ossuary","seed":99117,"offset":Vector3(3900,300,-1800)},
    {"name":"Thalen","seed":44712,"offset":Vector3(-3700,-200,-2600)},
    {"name":"Nyx Choir","seed":88103,"offset":Vector3(1700,500,-6100)},
    {"name":"Caldris","seed":31077,"offset":Vector3(-5400,200,-5100)},
    {"name":"The Aperture","seed":70007,"offset":Vector3(0,-300,-9200)},
]

func _ready() -> void:
    rng.seed = 20260725
    _build_environment()
    _build_starfield(5000)
    _build_system()
    _build_asteroid_field(1200)

func _build_environment() -> void:
    var environment := WorldEnvironment.new()
    var env := Environment.new()
    env.background_mode = Environment.BG_COLOR
    env.background_color = Color(0.0007, 0.0015, 0.004)
    env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    env.ambient_light_color = Color(0.075, 0.11, 0.16)
    env.ambient_light_energy = 0.42
    env.tonemap_mode = Environment.TONE_MAPPER_ACES
    env.tonemap_exposure = 1.1
    env.glow_enabled = true
    env.glow_intensity = 1.15
    env.glow_strength = 1.1
    env.glow_bloom = 0.16
    env.fog_enabled = true
    env.fog_light_color = Color(0.03, 0.06, 0.09)
    env.fog_density = 0.00012
    environment.environment = env
    add_child(environment)

func _build_starfield(count: int) -> void:
    var stars := MultiMeshInstance3D.new()
    stars.name = "HDRStarField"
    var multimesh := MultiMesh.new()
    multimesh.transform_format = MultiMesh.TRANSFORM_3D
    multimesh.use_colors = true
    multimesh.instance_count = count
    var star_mesh := SphereMesh.new()
    star_mesh.radius = 0.12
    star_mesh.height = 0.24
    star_mesh.radial_segments = 4
    star_mesh.rings = 2
    var star_material := StandardMaterial3D.new()
    star_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    star_material.emission_enabled = true
    star_material.emission = Color(0.82, 0.92, 1.0)
    star_material.emission_energy_multiplier = 4.0
    star_mesh.material = star_material
    multimesh.mesh = star_mesh
    for index in count:
        var direction := Vector3(rng.randf_range(-1.0,1.0),rng.randf_range(-0.72,0.72),rng.randf_range(-1.0,1.0)).normalized()
        var distance := rng.randf_range(900.0, 1900.0)
        var scale := rng.randf_range(0.45, 1.8)
        multimesh.set_instance_transform(index, Transform3D(Basis.IDENTITY.scaled(Vector3.ONE*scale), direction*distance))
        var temperature := rng.randf()
        multimesh.set_instance_color(index, Color(0.7+temperature*.3,0.72+temperature*.25,1.0-temperature*.2,1))
    stars.multimesh = multimesh
    add_child(stars)

func _build_system() -> void:
    star_visual = MeshInstance3D.new()
    var star_sphere := SphereMesh.new()
    star_sphere.radius = 24.0
    star_sphere.height = 48.0
    star_sphere.radial_segments = 64
    star_sphere.rings = 32
    var star_material := StandardMaterial3D.new()
    star_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    star_material.albedo_color = Color(0.64,0.85,1.0)
    star_material.emission_enabled = true
    star_material.emission = Color(0.45,0.72,1.0)
    star_material.emission_energy_multiplier = 8.0
    star_sphere.material = star_material
    star_visual.mesh = star_sphere
    star_visual.position = Vector3(-520,260,-1050)
    add_child(star_visual)
    star_light = DirectionalLight3D.new()
    star_light.light_color = Color(0.72,0.87,1.0)
    star_light.light_energy = 2.8
    star_light.shadow_enabled = true
    star_light.rotation_degrees = Vector3(-25,-145,0)
    add_child(star_light)

    var world_specs := [
        {"name":"Lyra IV","radius":76.0,"position":Vector3(50,-35,-460),"seed":5.4,"cities":1.25,"description":"Mineral-rich ocean world. Choir biosignatures persist beneath the cloud deck.","palette":{"abyss":Color("07131b"),"lowland":Color("205a63"),"highland":Color("b1a875"),"peak":Color("d4ccb0"),"water":Color("0b3342")}},
        {"name":"Vigil","radius":19.0,"position":Vector3(-112,38,-540),"seed":12.2,"sea":0.82,"atmosphere":false,"description":"Airless moon scored by ancient basin impacts.","palette":{"abyss":Color("17191b"),"lowland":Color("454844"),"highland":Color("8d8779"),"peak":Color("d1ccc1"),"water":Color("333333")}},
        {"name":"Sereph","radius":190.0,"position":Vector3(680,120,-1250),"seed":20.8,"sea":0.3,"rings":true,"ring_color":Color("c99678"),"cloud_coverage":0.39,"atmosphere_color":Color("ffa46b"),"description":"Massive ringed giant anchoring the outer system.","palette":{"abyss":Color("201216"),"lowland":Color("85513d"),"highland":Color("e4b477"),"peak":Color("ffe0ad"),"water":Color("63372d")}},
    ]
    for spec in world_specs:
        var body := PlanetBody.new().configure(spec)
        planets.append(body)
        add_child(body)
    _build_resonators()

func _build_resonators() -> void:
    var positions := [Vector3(22,12,-315),Vector3(-290,44,-620),Vector3(430,-80,-920),Vector3(-610,90,-1120),Vector3(900,160,-1580),Vector3(-1020,-90,-1720),Vector3(0,30,-2250)]
    for index in positions.size():
        var resonator := Node3D.new()
        resonator.name = "Resonator_%02d" % (index+1)
        resonator.position = positions[index]
        resonator.set_meta("scan_name", "RESONATOR %s" % (index+1))
        resonator.set_meta("description", "A Choir instrument waiting in perfect silence.")
        var material := StandardMaterial3D.new()
        material.metallic = 0.93
        material.roughness = 0.12
        material.albedo_color = Color(0.015,0.04,0.055)
        material.emission_enabled = true
        material.emission = Color(0.1,0.72,0.9)
        material.emission_energy_multiplier = 3.2
        for ring_index in 4:
            var ring_mesh := TorusMesh.new()
            ring_mesh.inner_radius = 5.5 + ring_index*3.2
            ring_mesh.outer_radius = ring_mesh.inner_radius + 0.22
            ring_mesh.rings = 96
            ring_mesh.ring_segments = 12
            var ring := MeshInstance3D.new()
            ring.mesh = ring_mesh
            ring.material_override = material
            ring.rotation = Vector3(ring_index*.57,ring_index*.32,ring_index*.19)
            resonator.add_child(ring)
        var core_mesh := SphereMesh.new()
        core_mesh.radius = 1.8
        core_mesh.height = 3.6
        var core := MeshInstance3D.new()
        core.mesh = core_mesh
        core.material_override = material
        resonator.add_child(core)
        resonators.append(resonator)
        add_child(resonator)

func _build_asteroid_field(count: int) -> void:
    asteroid_field = MultiMeshInstance3D.new()
    var multimesh := MultiMesh.new()
    multimesh.transform_format = MultiMesh.TRANSFORM_3D
    multimesh.instance_count = count
    var rock := SphereMesh.new()
    rock.radius = 1.0
    rock.height = 1.7
    rock.radial_segments = 7
    rock.rings = 5
    var rock_material := StandardMaterial3D.new()
    rock_material.albedo_color = Color(0.13,0.14,0.15)
    rock_material.roughness = 0.94
    rock.material = rock_material
    multimesh.mesh = rock
    for index in count:
        var angle := rng.randf_range(0,TAU)
        var radial := rng.randf_range(250.0,620.0)
        var p := Vector3(cos(angle)*radial,rng.randf_range(-55,55),-720+sin(angle)*radial)
        var basis := Basis.from_euler(Vector3(rng.randf()*TAU,rng.randf()*TAU,rng.randf()*TAU))
        var scale := rng.randf_range(0.18,3.8)
        basis = basis.scaled(Vector3(scale,rng.randf_range(.55,1.2)*scale,rng.randf_range(.65,1.3)*scale))
        multimesh.set_instance_transform(index,Transform3D(basis,p))
    asteroid_field.multimesh = multimesh
    add_child(asteroid_field)

func get_nearest_scannable(point: Vector3) -> Node3D:
    var best: Node3D
    var best_distance := INF
    for body in planets:
        var distance := body.distance_to_surface(point)
        if distance < best_distance:
            best_distance = distance
            best = body
    for resonator in resonators:
        var distance := point.distance_to(resonator.global_position)
        if distance < best_distance:
            best_distance = distance
            best = resonator
    return best

func target_distance(point: Vector3, target: Node3D) -> float:
    if target is PlanetBody:
        return (target as PlanetBody).distance_to_surface(point)
    return point.distance_to(target.global_position)
