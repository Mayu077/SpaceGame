class_name NativeShip
extends Node3D

signal mode_changed(mode_name: String)
signal speed_changed(speed_value: float)

const MODE_WALK := 0
const MODE_PILOT := 1
const MODE_CHASE := 2
const MODE_SURFACE := 3

var mode := MODE_WALK
var velocity := Vector3.ZERO
var throttle := 0.0
var boost_charge := 1.0
var mouse_delta := Vector2.ZERO
var walk_position := Vector3(0,1.7,5.0)
var yaw := 0.0
var pitch := 0.0
var roll := 0.0
var camera: Camera3D
var cockpit: Node3D
var exterior: Node3D
var pilot_seat := Vector3(0,1.7,-2.5)
var hull_material: StandardMaterial3D
var dark_material: StandardMaterial3D
var emissive_material: StandardMaterial3D
var is_input_enabled := false

func _ready() -> void:
    _create_materials()
    _build_cockpit()
    _build_exterior()
    camera = Camera3D.new()
    camera.name = "PlayerCamera"
    camera.fov = 66.0
    camera.near = 0.03
    camera.far = 6000.0
    add_child(camera)
    _set_mode(MODE_WALK)

func _create_materials() -> void:
    hull_material = StandardMaterial3D.new()
    hull_material.albedo_color = Color(0.16,0.19,0.21)
    hull_material.metallic = 0.88
    hull_material.roughness = 0.31
    dark_material = StandardMaterial3D.new()
    dark_material.albedo_color = Color(0.018,0.025,0.03)
    dark_material.metallic = 0.78
    dark_material.roughness = 0.48
    emissive_material = StandardMaterial3D.new()
    emissive_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    emissive_material.albedo_color = Color(0.3,0.9,1.0)
    emissive_material.emission_enabled = true
    emissive_material.emission = Color(0.15,0.78,1.0)
    emissive_material.emission_energy_multiplier = 5.0

func _box(parent: Node3D, size: Vector3, pos: Vector3, material: Material, rotation_value := Vector3.ZERO) -> MeshInstance3D:
    var instance := MeshInstance3D.new()
    var box := BoxMesh.new()
    box.size = size
    instance.mesh = box
    instance.position = pos
    instance.rotation = rotation_value
    instance.material_override = material
    parent.add_child(instance)
    return instance

func _cylinder(parent: Node3D, top: float, bottom: float, height: float, pos: Vector3, material: Material, rotation_value := Vector3.ZERO) -> MeshInstance3D:
    var instance := MeshInstance3D.new()
    var cylinder := CylinderMesh.new()
    cylinder.top_radius = top
    cylinder.bottom_radius = bottom
    cylinder.height = height
    cylinder.radial_segments = 24
    instance.mesh = cylinder
    instance.position = pos
    instance.rotation = rotation_value
    instance.material_override = material
    parent.add_child(instance)
    return instance

func _build_cockpit() -> void:
    cockpit = Node3D.new()
    cockpit.name = "PaleSeekerInterior"
    add_child(cockpit)
    _box(cockpit,Vector3(5.8,.24,20),Vector3(0,0,4),dark_material)
    _box(cockpit,Vector3(5.8,.18,20),Vector3(0,4,4),hull_material)
    for side in [-1.0,1.0]:
        _box(cockpit,Vector3(.2,4,20),Vector3(side*2.8,2,4),dark_material)
        for z in range(-4,13,2):
            _box(cockpit,Vector3(.08,.07,1.25),Vector3(side*2.67,3.56,z),emissive_material)
    for z in range(-5,14,2):
        _box(cockpit,Vector3(5.65,.12,.16),Vector3(0,3.72,z),hull_material)
        _box(cockpit,Vector3(.14,3.55,.16),Vector3(-2.67,1.9,z),hull_material)
        _box(cockpit,Vector3(.14,3.55,.16),Vector3(2.67,1.9,z),hull_material)
    # Instrument dashboard and side consoles.
    _box(cockpit,Vector3(5.45,.68,1.75),Vector3(0,.62,-5.05),dark_material,Vector3(-.18,0,0))
    for side in [-1.0,1.0]:
        _box(cockpit,Vector3(.76,.8,3.5),Vector3(side*2.25,.53,-3.2),dark_material,Vector3(0,0,side*.1))
        for row in 5:
            for col in 3:
                var lamp := emissive_material if (row+col)%4 else _amber_material()
                _box(cockpit,Vector3(.1,.035,.1),Vector3(side*(2.0+col*.18),.97,-4.35+row*.33),lamp)
    # Pilot chair.
    _box(cockpit,Vector3(1.35,.35,1.3),Vector3(0,.48,-1.45),dark_material)
    _box(cockpit,Vector3(1.28,1.85,.28),Vector3(0,1.4,-.95),dark_material,Vector3(-.12,0,0))
    for side in [-1.0,1.0]:
        _box(cockpit,Vector3(.22,.7,.25),Vector3(side*.83,.72,-1.48),hull_material)
    # Engineering bay and illuminated reactor cylinders.
    for x in [-1.65,0.0,1.65]:
        _cylinder(cockpit,.5,.62,2.5,Vector3(x,1.4,9.7),dark_material)
        _cylinder(cockpit,.42,.42,1.52,Vector3(x,1.42,9.7),emissive_material)
    # Local practical lights.
    var cabin_light := OmniLight3D.new()
    cabin_light.light_color = Color(0.45,0.88,1.0)
    cabin_light.light_energy = 4.0
    cabin_light.omni_range = 15.0
    cabin_light.position = Vector3(0,3.2,1)
    cockpit.add_child(cabin_light)
    var rear_light := OmniLight3D.new()
    rear_light.light_color = Color(1.0,.32,.12)
    rear_light.light_energy = 2.2
    rear_light.omni_range = 7.0
    rear_light.position = Vector3(0,1,9)
    cockpit.add_child(rear_light)
    # Try the original generated hard-surface kit as additional detail.
    if ResourceLoader.exists("res://public/models/interior_kit.glb"):
        var kit_resource = load("res://public/models/interior_kit.glb")
        if kit_resource is PackedScene:
            var kit := (kit_resource as PackedScene).instantiate()
            kit.name = "OriginalInteriorHardSurfaceKit"
            kit.scale = Vector3.ONE * 0.01
            cockpit.add_child(kit)

func _amber_material() -> StandardMaterial3D:
    var material := emissive_material.duplicate() as StandardMaterial3D
    material.albedo_color = Color(1.0,.49,.12)
    material.emission = Color(1.0,.28,.05)
    return material

func _build_exterior() -> void:
    exterior = Node3D.new()
    exterior.name = "PaleSeekerExterior"
    add_child(exterior)
    _cylinder(exterior,2.15,2.7,14,Vector3(0,1,1),hull_material,Vector3(PI/2,0,0))
    _cylinder(exterior,0.08,2.15,5.5,Vector3(0,1,-8.7),hull_material,Vector3(PI/2,0,0))
    for side in [-1.0,1.0]:
        _box(exterior,Vector3(7.4,.25,5.8),Vector3(side*4.1,.55,1.8),hull_material,Vector3(0,side*.08,side*-.045))
        for bank in 2:
            var x := side*(4.3+bank*1.2)
            _cylinder(exterior,.7,.95,6.2,Vector3(x,.45,3.1),dark_material,Vector3(PI/2,0,0))
            var engine_light := OmniLight3D.new()
            engine_light.light_color = Color(.22,.78,1)
            engine_light.light_energy = 3.0
            engine_light.omni_range = 8.0
            engine_light.position = Vector3(x,.45,6.3)
            exterior.add_child(engine_light)
    for z in range(-4,7):
        _box(exterior,Vector3(4.6,.04,.045),Vector3(0,2.25,z),emissive_material)
    exterior.visible = false

func enable_input() -> void:
    is_input_enabled = true
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
        mouse_delta += event.relative
    if event is InputEventMouseButton and event.pressed:
        Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
    if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
        Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
    if event.is_action_pressed("camera_toggle") and mode in [MODE_PILOT,MODE_CHASE]:
        _set_mode(MODE_CHASE if mode == MODE_PILOT else MODE_PILOT)
    if event.is_action_pressed("interact"):
        if mode == MODE_WALK and walk_position.z < 1.2:
            _set_mode(MODE_PILOT)
        elif mode in [MODE_PILOT,MODE_CHASE]:
            _set_mode(MODE_WALK)

func _physics_process(delta: float) -> void:
    if not is_input_enabled:
        return
    match mode:
        MODE_PILOT, MODE_CHASE:
            _flight_update(delta)
        MODE_WALK, MODE_SURFACE:
            _walk_update(delta)

func _flight_update(delta: float) -> void:
    var boost := Input.is_action_pressed("boost") and boost_charge > 0.02
    var target_limit := 155.0 if boost else 72.0
    if Input.is_action_pressed("thrust_forward"):
        throttle = move_toward(throttle,1.0,delta*.55)
    elif Input.is_action_pressed("thrust_back"):
        throttle = move_toward(throttle,-.35,delta*.75)
    else:
        throttle = move_toward(throttle,0.0,delta*.2)
    var forward := -global_transform.basis.z
    velocity += forward * throttle * (46.0 if boost else 22.0) * delta
    if Input.is_action_pressed("brake"):
        velocity = velocity.lerp(Vector3.ZERO,1.0-exp(-3.8*delta))
    if velocity.length() > target_limit:
        velocity = velocity.normalized()*target_limit
    position += velocity*delta
    var steer := Vector2(
        Input.get_axis("strafe_left","strafe_right"),
        Input.get_axis("thrust_forward","thrust_back")*0.0
    )
    yaw -= mouse_delta.x*.00125 + steer.x*delta*.55
    pitch = clamp(pitch-mouse_delta.y*.00115,-.72,.72)
    roll = move_toward(roll,Input.get_axis("roll_right","roll_left")*.7-yaw*.04,delta*1.8)
    quaternion = quaternion.slerp(Quaternion.from_euler(Vector3(pitch,yaw,roll)),1.0-exp(-3.1*delta))
    mouse_delta = Vector2.ZERO
    if boost:
        boost_charge = max(0.0,boost_charge-delta*.13)
    else:
        boost_charge = min(1.0,boost_charge+delta*.045)
    camera.fov = lerp(camera.fov,76.0 if boost else (60.0 if mode==MODE_CHASE else 66.0),1.0-exp(-3.0*delta))
    if mode == MODE_PILOT:
        camera.position = camera.position.lerp(pilot_seat,1.0-exp(-8.0*delta))
        camera.rotation = Vector3.ZERO
    else:
        camera.position = camera.position.lerp(Vector3(0,6.2,18),1.0-exp(-4.0*delta))
        camera.rotation.x = lerp(camera.rotation.x,-.28,1.0-exp(-4.0*delta))
    speed_changed.emit(velocity.length())

func _walk_update(delta: float) -> void:
    yaw -= mouse_delta.x*.0016
    pitch = clamp(pitch-mouse_delta.y*.0015,-1.1,1.1)
    mouse_delta = Vector2.ZERO
    var input := Input.get_vector("strafe_left","strafe_right","thrust_forward","thrust_back")
    var direction := Vector3(input.x,0,input.y).rotated(Vector3.UP,yaw)
    var walk_speed := 7.0 if Input.is_action_pressed("boost") else 3.4
    walk_position += direction*walk_speed*delta
    if mode == MODE_WALK:
        walk_position.x = clamp(walk_position.x,-2.35,2.35)
        walk_position.z = clamp(walk_position.z,-2.8,12.0)
        walk_position.y = 1.7
    camera.position = walk_position
    camera.rotation = Vector3(pitch,yaw,0)

func _set_mode(new_mode: int) -> void:
    mode = new_mode
    cockpit.visible = mode != MODE_CHASE and mode != MODE_SURFACE
    exterior.visible = mode == MODE_CHASE
    if mode == MODE_WALK:
        walk_position = Vector3(0,1.7,-.3)
        yaw = 0.0
        pitch = 0.0
    elif mode == MODE_PILOT:
        camera.position = pilot_seat
        camera.rotation = Vector3.ZERO
    elif mode == MODE_CHASE:
        camera.position = Vector3(0,6.2,18)
        camera.rotation = Vector3(-.28,0,0)
    mode_changed.emit(["WALK","PILOT","CHASE","SURFACE"][mode])

func enter_surface(spawn: Vector3) -> void:
    velocity = Vector3.ZERO
    walk_position = spawn
    yaw = PI
    pitch = 0.0
    _set_mode(MODE_SURFACE)

func return_to_pilot() -> void:
    _set_mode(MODE_PILOT)
