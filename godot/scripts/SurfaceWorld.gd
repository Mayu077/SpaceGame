class_name SurfaceWorld
extends Node3D

var terrain_noise := FastNoiseLite.new()
var detail_noise := FastNoiseLite.new()
var terrain_size := 520.0
var resolution := 150
var monolith: Node3D
var landing_ship: Node3D

func build(seed_value: int = 540) -> void:
    terrain_noise.seed = seed_value
    terrain_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
    terrain_noise.frequency = 0.008
    terrain_noise.fractal_type = FastNoiseLite.FRACTAL_FBM
    terrain_noise.fractal_octaves = 6
    terrain_noise.fractal_gain = 0.48
    detail_noise.seed = seed_value*13
    detail_noise.frequency = .035
    detail_noise.fractal_octaves = 4
    _build_terrain()
    _build_rocks(900)
    _build_monolith()
    _build_landed_ship()
    _build_atmosphere()

func height_at(x: float,z: float) -> float:
    return terrain_noise.get_noise_2d(x,z)*16.0+detail_noise.get_noise_2d(x,z)*2.1

func _build_terrain() -> void:
    var vertices := PackedVector3Array()
    var normals := PackedVector3Array()
    var uvs := PackedVector2Array()
    var indices := PackedInt32Array()
    for z_index in resolution+1:
        for x_index in resolution+1:
            var x := (float(x_index)/resolution-.5)*terrain_size
            var z := (float(z_index)/resolution-.5)*terrain_size
            vertices.append(Vector3(x,height_at(x,z),z))
            uvs.append(Vector2(float(x_index)/resolution,float(z_index)/resolution)*32.0)
            var epsilon := 1.2
            var normal := Vector3(height_at(x-epsilon,z)-height_at(x+epsilon,z),epsilon*2.0,height_at(x,z-epsilon)-height_at(x,z+epsilon)).normalized()
            normals.append(normal)
    for z_index in resolution:
        for x_index in resolution:
            var a := z_index*(resolution+1)+x_index
            var b := a+1
            var c := a+(resolution+1)
            var d := c+1
            indices.append_array([a,c,b,b,c,d])
    var arrays := []
    arrays.resize(Mesh.ARRAY_MAX)
    arrays[Mesh.ARRAY_VERTEX]=vertices
    arrays[Mesh.ARRAY_NORMAL]=normals
    arrays[Mesh.ARRAY_TEX_UV]=uvs
    arrays[Mesh.ARRAY_INDEX]=indices
    var mesh := ArrayMesh.new()
    mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,arrays)
    var terrain := MeshInstance3D.new()
    terrain.name="LyraSurfaceTerrain"
    terrain.mesh=mesh
    var material := StandardMaterial3D.new()
    material.albedo_color=Color(.14,.16,.17)
    material.roughness=.92
    var rock_texture=load("res://public/models/terr_rock.webp")
    if rock_texture:
        material.albedo_texture=rock_texture
        material.uv1_scale=Vector3(32,32,32)
    terrain.material_override=material
    add_child(terrain)

func _build_rocks(count: int) -> void:
    var instance := MultiMeshInstance3D.new()
    var multimesh := MultiMesh.new()
    multimesh.transform_format=MultiMesh.TRANSFORM_3D
    multimesh.instance_count=count
    var rock := SphereMesh.new()
    rock.radius=1.0
    rock.height=1.5
    rock.radial_segments=7
    rock.rings=5
    var material := StandardMaterial3D.new()
    material.albedo_color=Color(.12,.13,.14)
    material.roughness=.96
    rock.material=material
    multimesh.mesh=rock
    var rng:=RandomNumberGenerator.new();rng.seed=84911
    for index in count:
        var x:=rng.randf_range(-terrain_size*.47,terrain_size*.47)
        var z:=rng.randf_range(-terrain_size*.47,terrain_size*.47)
        var s:=pow(rng.randf(),2.0)*3.4+.12
        var basis:=Basis.from_euler(Vector3(rng.randf()*TAU,rng.randf()*TAU,rng.randf()*TAU)).scaled(Vector3(s,rng.randf_range(.45,1.1)*s,rng.randf_range(.55,1.3)*s))
        multimesh.set_instance_transform(index,Transform3D(basis,Vector3(x,height_at(x,z)+s*.25,z)))
    instance.multimesh=multimesh
    add_child(instance)

func _build_monolith() -> void:
    monolith=Node3D.new();monolith.name="ChoirSurfaceResonator";monolith.position=Vector3(0,height_at(0,-92),-92)
    monolith.set_meta("scan_name","BURIED RESONATOR")
    monolith.set_meta("description","An instrument older than the ruins around it. It is listening.")
    var crystal_material:=StandardMaterial3D.new();crystal_material.albedo_color=Color(.02,.12,.16);crystal_material.metallic=.65;crystal_material.roughness=.16;crystal_material.emission_enabled=true;crystal_material.emission=Color(.05,.76,1);crystal_material.emission_energy_multiplier=4.0
    var rng:=RandomNumberGenerator.new();rng.seed=77
    for index in 11:
        var crystal:=MeshInstance3D.new();var cone:=PrismMesh.new();cone.size=Vector3(rng.randf_range(.5,1.5),rng.randf_range(5,16),rng.randf_range(.5,1.5));crystal.mesh=cone;crystal.position=Vector3(rng.randf_range(-5,5),cone.size.y*.5,rng.randf_range(-4,4));crystal.rotation.z=rng.randf_range(-.28,.28);crystal.material_override=crystal_material;monolith.add_child(crystal)
    add_child(monolith)

func _build_landed_ship() -> void:
    landing_ship=Node3D.new();landing_ship.name="LandedPaleSeeker";landing_ship.position=Vector3(0,height_at(0,38)+2,38);landing_ship.set_meta("scan_name","PALE SEEKER");landing_ship.set_meta("description","Return to orbit")
    var hull:=StandardMaterial3D.new();hull.albedo_color=Color(.18,.21,.23);hull.metallic=.88;hull.roughness=.34
    var body:=MeshInstance3D.new();var cylinder:=CylinderMesh.new();cylinder.top_radius=1.3;cylinder.bottom_radius=2.4;cylinder.height=9;cylinder.radial_segments=20;body.mesh=cylinder;body.rotation.x=PI/2;body.position.y=3.8;body.material_override=hull;landing_ship.add_child(body)
    for side in [-1.0,1.0]:
        for z_side in [-1.0,1.0]:
            var leg:=MeshInstance3D.new();var leg_mesh:=CylinderMesh.new();leg_mesh.top_radius=.12;leg_mesh.bottom_radius=.18;leg_mesh.height=5;leg.mesh=leg_mesh;leg.position=Vector3(side*2.5,1.5,z_side*2.4);leg.rotation.z=side*.48;leg.material_override=hull;landing_ship.add_child(leg)
    add_child(landing_ship)

func _build_atmosphere() -> void:
    var light:=DirectionalLight3D.new();light.light_color=Color(1.0,.72,.56);light.light_energy=2.7;light.rotation_degrees=Vector3(-38,-125,0);light.shadow_enabled=true;add_child(light)
    var environment:=WorldEnvironment.new();var env:=Environment.new();env.background_mode=Environment.BG_COLOR;env.background_color=Color(.015,.035,.065);env.ambient_light_source=Environment.AMBIENT_SOURCE_COLOR;env.ambient_light_color=Color(.18,.26,.32);env.ambient_light_energy=.75;env.tonemap_mode=Environment.TONE_MAPPER_ACES;env.glow_enabled=true;env.glow_intensity=1.25;env.fog_enabled=true;env.fog_light_color=Color(.22,.15,.16);env.fog_density=.008;environment.environment=env;add_child(environment)
