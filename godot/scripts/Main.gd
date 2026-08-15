extends Node3D

var universe: NativeUniverse
var ship: NativeShip
var hud: NativeHUD
var audio: NativeAudio
var surface: SurfaceWorld
var started := false
var landed := false
var scan_value := 0.0
var scanned_ids: Dictionary = {}
var resonance := 0
var fold_index := 0
var current_target: Node3D
var time := 0.0

const CANTOS := [
    "THE FIRST CANTO — The sky is not empty. It is holding its breath.",
    "THE SECOND CANTO — The stars are the punctuation. We had been reading the gaps.",
    "THE THIRD CANTO — We were so proud to be heard that we forgot to ask who was listening.",
    "THE FOURTH CANTO — A civilisation that leaves the door unlocked did not flee. It walked.",
    "THE FIFTH CANTO — Distance was a habit of ours. We are trying to break it.",
    "THE SIXTH CANTO — Consider carefully whether you want the seventh.",
    "THE SEVENTH CANTO — This is the long silence. It is full of everyone who came before you.",
]

func _ready() -> void:
    _register_inputs()
    universe=NativeUniverse.new();universe.name="NativeUniverse";add_child(universe)
    ship=NativeShip.new();ship.name="PaleSeeker";ship.position=Vector3(0,4,18);add_child(ship)
    hud=NativeHUD.new();hud.name="NativeHUD";add_child(hud)
    audio=NativeAudio.new();audio.name="ProceduralAudio";add_child(audio)
    hud.wake_requested.connect(_wake)
    ship.speed_changed.connect(hud.set_speed)
    ship.speed_changed.connect(audio.set_engine)
    ship.mode_changed.connect(hud.set_mode)
    current_target=universe.resonators[0]
    hud.set_target("RESONATOR I",ship.position.distance_to(current_target.position))

func _register_inputs() -> void:
    var bindings := {
        "thrust_forward": KEY_W, "thrust_back": KEY_S,
        "strafe_left": KEY_A, "strafe_right": KEY_D,
        "roll_left": KEY_Q, "roll_right": KEY_E,
        "boost": KEY_SHIFT, "brake": KEY_X, "interact": KEY_E,
        "scan": KEY_F, "land": KEY_L, "fold": KEY_J,
        "map": KEY_M, "archive": KEY_TAB, "camera_toggle": KEY_V,
    }
    for action in bindings:
        if not InputMap.has_action(action):
            InputMap.add_action(action)
        var event := InputEventKey.new()
        event.physical_keycode = bindings[action]
        InputMap.action_add_event(action,event)

func _wake() -> void:
    if started:return
    started=true;hud.begin();ship.enable_input();hud.log_message("SCANNER ONLINE",Color(.42,1,.72));hud.log_message("SYSTEM · ASTER REACH");hud.objective_label.text="DIRECTIVE\nATTUNE THE FIRST RESONATOR"

func _unhandled_input(event:InputEvent) -> void:
    if not started:return
    if event.is_action_pressed("archive"):hud.toggle_archive()
    if event.is_action_pressed("map"):hud.toggle_map()
    if event.is_action_pressed("land"):_attempt_landing()
    if event.is_action_pressed("fold"):_attempt_fold()
    if event.is_action_pressed("interact") and landed:
        var distance:=Vector2(ship.walk_position.x-surface.landing_ship.position.x,ship.walk_position.z-surface.landing_ship.position.z).length()
        if distance<10.0:_return_to_orbit()

func _process(delta:float) -> void:
    time+=delta
    if not started:return
    if landed:
        _surface_update(delta)
    else:
        _space_update(delta)
    _scan_update(delta)
    for index in universe.resonators.size():
        var resonator:=universe.resonators[index]
        resonator.rotation.y=time*(.07+index*.008)
        if resonator.get_child_count()>index%4:
            resonator.get_child(index%4).rotation.x+=delta*.13

func _space_update(_delta:float) -> void:
    current_target=universe.get_nearest_scannable(ship.global_position)
    if current_target:
        var target_name:=current_target.body_name if current_target is PlanetBody else current_target.get_meta("scan_name","UNKNOWN SIGNAL")
        hud.set_target(target_name,universe.target_distance(ship.global_position,current_target))
    # Floating origin keeps native 32-bit transforms precise over interstellar distances.
    if ship.position.length()>1400.0:
        var shift:=ship.position
        ship.position=Vector3.ZERO
        for body in universe.planets:body.position-=shift
        for resonator in universe.resonators:resonator.position-=shift
        universe.star_visual.position-=shift
        universe.asteroid_field.position-=shift

func _surface_update(_delta:float) -> void:
    ship.walk_position.y=surface.height_at(ship.walk_position.x,ship.walk_position.z)+1.7
    var to_monolith:=Vector2(ship.walk_position.x-surface.monolith.position.x,ship.walk_position.z-surface.monolith.position.z).length()
    var to_ship:=Vector2(ship.walk_position.x-surface.landing_ship.position.x,ship.walk_position.z-surface.landing_ship.position.z).length()
    current_target=surface.monolith if to_monolith<to_ship else surface.landing_ship
    hud.set_target(current_target.get_meta("scan_name","SURFACE SIGNAL"),min(to_monolith,to_ship))
    hud.prompt_label.visible=to_ship<11.0

func _scan_update(delta:float) -> void:
    if not current_target:return
    var distance:float
    if landed:
        distance=Vector2(ship.walk_position.x-current_target.position.x,ship.walk_position.z-current_target.position.z).length()
    else:
        distance=universe.target_distance(ship.global_position,current_target)
    var range_limit:=18.0 if landed else 48.0
    var scanning:=Input.is_action_pressed("scan") and distance<range_limit
    audio.set_scanning(scanning)
    if scanning:
        scan_value=min(1.0,scan_value+delta*.34);hud.set_scan(true,scan_value)
        if scan_value>=1.0:_complete_scan(current_target)
    else:
        scan_value=max(0.0,scan_value-delta*.15);hud.set_scan(false,scan_value)

func _complete_scan(target:Node3D) -> void:
    var id:=str(target.get_instance_id())
    if scanned_ids.has(id):return
    scanned_ids[id]=true;scan_value=0.0
    var title:=target.body_name if target is PlanetBody else target.get_meta("scan_name","UNKNOWN")
    hud.log_message("SCAN COMPLETE · "+title.to_upper(),Color(.45,1,.72))
    if target.name.begins_with("Resonator") or (surface != null and target==surface.monolith):
        resonance=min(7,resonance+1);hud.set_resonance(resonance);hud.log_message(CANTOS[resonance-1],Color(1,.72,.42));hud.objective_label.text="DIRECTIVE\nLOCATE RESONATOR %d"%min(7,resonance+1)
        if resonance==7:hud.objective_label.text="THE APERTURE IS OPEN\nCHOOSE WHETHER TO ENTER"

func _attempt_landing() -> void:
    if landed:return
    var nearest:PlanetBody
    var distance:=INF
    for planet in universe.planets:
        var d:=planet.distance_to_surface(ship.position)
        if d<distance:distance=d;nearest=planet
    if nearest and distance<45.0:
        hud.transition("ENTERING "+nearest.body_name.to_upper()+" ATMOSPHERE",func():_begin_surface(nearest))
    else:hud.log_message("PLANETFALL VECTOR UNAVAILABLE · APPROACH A WORLD",Color(1,.45,.3))

func _begin_surface(_planet:PlanetBody) -> void:
    landed=true;universe.visible=false;audio.set_surface(true)
    surface=SurfaceWorld.new();surface.name="PlanetarySurface";add_child(surface);surface.build(540)
    ship.position=Vector3.ZERO;ship.quaternion=Quaternion.IDENTITY;ship.enter_surface(Vector3(0,surface.height_at(0,26)+1.7,26));hud.objective_label.text="SURFACE EXPEDITION\nTRACE THE RESONATOR SIGNAL";hud.set_mode("SURFACE")

func _return_to_orbit() -> void:
    hud.transition("RETURNING TO ORBIT",func():
        landed=false;surface.queue_free();surface=null;universe.visible=true;audio.set_surface(false);ship.position=Vector3(68,-12,-350);ship.quaternion=Quaternion.IDENTITY;ship.return_to_pilot();hud.objective_label.text="DIRECTIVE\nCONTINUE THE RESONATOR SURVEY")

func _attempt_fold() -> void:
    if landed:hud.log_message("FOLD INHIBITED INSIDE GRAVITY WELL",Color(1,.45,.3));return
    if ship.velocity.length()>95.0:hud.log_message("REDUCE VELOCITY BEFORE FOLD",Color(1,.45,.3));return
    fold_index=(fold_index+1)%universe.resonators.size()
    var destination:=universe.resonators[fold_index]
    hud.transition("FOLD · "+destination.get_meta("scan_name","UNKNOWN"),func():
        ship.position=destination.position+Vector3(0,4,95);ship.velocity=Vector3.ZERO;ship.quaternion=Quaternion.IDENTITY;hud.log_message("FOLD COMPLETE",Color(.42,1,.72)))
