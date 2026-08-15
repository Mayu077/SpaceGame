class_name NativeHUD
extends CanvasLayer

signal wake_requested

var boot: ColorRect
var objective_label: Label
var speed_label: Label
var target_label: Label
var distance_label: Label
var mode_label: Label
var scan_panel: Control
var scan_progress: ProgressBar
var prompt_label: Label
var archive_panel: PanelContainer
var map_panel: PanelContainer
var canto_label: Label
var fade: ColorRect
var log_container: VBoxContainer

func _ready() -> void:
    layer=20
    _build_boot()
    _build_flight_hud()
    _build_panels()
    _build_fade()

func _label(text_value:String,size:int=14,color:=Color(.7,.9,.96)) -> Label:
    var label:=Label.new();label.text=text_value;label.add_theme_font_size_override("font_size",size);label.add_theme_color_override("font_color",color);return label

func _build_boot() -> void:
    boot=ColorRect.new();boot.color=Color(0.002,0.005,0.01,1);boot.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);add_child(boot)
    var center:=VBoxContainer.new();center.set_anchors_preset(Control.PRESET_CENTER);center.position=Vector2(-310,-160);center.custom_minimum_size=Vector2(620,320);center.alignment=BoxContainer.ALIGNMENT_CENTER;boot.add_child(center)
    var eyebrow:=_label("D E E P   S U R V E Y   V E S S E L   ·   P A L E   S E E K E R",13,Color(.32,.86,1));eyebrow.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;center.add_child(eyebrow)
    var title:=_label("THE LONG SILENCE",54,Color(.88,.96,1));title.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;center.add_child(title)
    var subtitle:=_label("Forty thousand years ago, nine hundred worlds went quiet in four days.",16,Color(.48,.59,.64));subtitle.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;center.add_child(subtitle)
    var spacer:=Control.new();spacer.custom_minimum_size.y=32;center.add_child(spacer)
    var wake:=Button.new();wake.text="WAKE";wake.custom_minimum_size=Vector2(220,52);wake.size_flags_horizontal=Control.SIZE_SHRINK_CENTER;wake.pressed.connect(func(): wake_requested.emit());center.add_child(wake)
    var legal:=_label("native Vulkan renderer · headphones recommended",11,Color(.3,.38,.42));legal.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;center.add_child(legal)

func _build_flight_hud() -> void:
    var top:=HBoxContainer.new();top.set_anchors_preset(Control.PRESET_TOP_WIDE);top.offset_left=38;top.offset_right=-38;top.offset_top=24;top.offset_bottom=80;top.add_theme_constant_override("separation",36);add_child(top)
    var ship_name:=_label("PALE SEEKER\nDEEP SURVEY VESSEL",15,Color(.65,.92,1));ship_name.size_flags_horizontal=Control.SIZE_EXPAND_FILL;top.add_child(ship_name)
    objective_label=_label("DIRECTIVE\nREACH THE FIRST RESONATOR",14,Color(.85,.93,.95));objective_label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;objective_label.size_flags_horizontal=Control.SIZE_EXPAND_FILL;top.add_child(objective_label)
    mode_label=_label("WALK\nSYSTEMS NOMINAL",14,Color(.54,1,.72));mode_label.horizontal_alignment=HORIZONTAL_ALIGNMENT_RIGHT;mode_label.size_flags_horizontal=Control.SIZE_EXPAND_FILL;top.add_child(mode_label)
    var center:=CenterContainer.new();center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);center.mouse_filter=Control.MOUSE_FILTER_IGNORE;add_child(center)
    var reticle:=_label("⌾",35,Color(.45,.9,1,.6));center.add_child(reticle)
    target_label=_label("UNIDENTIFIED SIGNAL",13,Color(.64,.92,1));target_label.position=Vector2(40,125);add_child(target_label)
    distance_label=_label("— KM",12,Color(.38,.76,.84));distance_label.position=Vector2(40,147);add_child(distance_label)
    speed_label=_label("000 M/S",32,Color(.8,.95,1));speed_label.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT);speed_label.position=Vector2(-185,-85);add_child(speed_label)
    canto_label=_label("RESONANCE  0 / 7",13,Color(.55,.85,.92));canto_label.set_anchors_preset(Control.PRESET_TOP_RIGHT);canto_label.position=Vector2(-210,110);add_child(canto_label)
    prompt_label=_label("E  TAKE PILOT SEAT",13,Color(.88,.95,1));prompt_label.set_anchors_preset(Control.PRESET_BOTTOM_WIDE);prompt_label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;prompt_label.position.y=-72;add_child(prompt_label)
    log_container=VBoxContainer.new();log_container.position=Vector2(38,190);log_container.custom_minimum_size=Vector2(420,200);add_child(log_container)
    scan_panel=VBoxContainer.new();scan_panel.set_anchors_preset(Control.PRESET_CENTER);scan_panel.position=Vector2(-170,-80);scan_panel.custom_minimum_size=Vector2(340,160);scan_panel.visible=false;add_child(scan_panel)
    var scan_title:=_label("QUANTUM SPECTROMETER",16,Color(.45,.92,1));scan_title.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;scan_panel.add_child(scan_title)
    scan_progress=ProgressBar.new();scan_progress.max_value=100;scan_progress.show_percentage=true;scan_progress.custom_minimum_size=Vector2(340,38);scan_panel.add_child(scan_progress)
    var hint:=_label("HOLD F TO RESOLVE",11,Color(.43,.58,.63));hint.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;scan_panel.add_child(hint)

func _build_panels() -> void:
    archive_panel=PanelContainer.new();archive_panel.set_anchors_preset(Control.PRESET_CENTER);archive_panel.position=Vector2(-420,-285);archive_panel.custom_minimum_size=Vector2(840,570);archive_panel.visible=false;add_child(archive_panel)
    var archive_text:=_label("ARCHIVE\n\nPALE SEEKER — COMMISSION\n\nYou are the eleven hundred and first.\nChart what you can. Scan what you find. Attune what will let you.\n\nTHE FIRST CANTO\n\nThe sky is not empty. It is holding its breath.\n\n[ TAB ]  CLOSE",17,Color(.72,.84,.88));archive_text.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;archive_text.custom_minimum_size=Vector2(760,500);archive_panel.add_child(archive_text)
    map_panel=PanelContainer.new();map_panel.set_anchors_preset(Control.PRESET_CENTER);map_panel.position=Vector2(-440,-300);map_panel.custom_minimum_size=Vector2(880,600);map_panel.visible=false;add_child(map_panel)
    var map_text:=_label("STELLAR CARTOGRAPHY\n\n      ◉ ASTER REACH  — CURRENT\n\n  · VEYRA        · OSSUARY        · THALEN\n\n       · NYX CHOIR       · CALDRIS\n\n                    ◇ THE APERTURE\n\nSelect a vector in flight and press J to engage FOLD.\n\n[ M ]  CLOSE",18,Color(.62,.88,.96));map_text.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;map_text.vertical_alignment=VERTICAL_ALIGNMENT_CENTER;map_panel.add_child(map_text)

func _build_fade() -> void:
    fade=ColorRect.new();fade.color=Color(0,0,0,0);fade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);fade.mouse_filter=Control.MOUSE_FILTER_IGNORE;fade.z_index=100;add_child(fade)

func begin() -> void:
    var tween:=create_tween();tween.tween_property(boot,"modulate:a",0.0,1.1);tween.tween_callback(func():boot.visible=false)

func set_speed(value:float) -> void:
    speed_label.text="%03d M/S"%roundi(value)

func set_mode(value:String) -> void:
    mode_label.text=value+"\nSYSTEMS NOMINAL"
    prompt_label.text="E  TAKE PILOT SEAT" if value=="WALK" else ("E  LEAVE PILOT SEAT" if value in ["PILOT","CHASE"] else "E  BOARD PALE SEEKER")

func set_target(name_value:String,distance:float) -> void:
    target_label.text=name_value.to_upper();distance_label.text="%.1f KM"%distance

func set_scan(active:bool,progress:float) -> void:
    scan_panel.visible=active;scan_progress.value=progress*100.0

func set_resonance(value:int) -> void:
    canto_label.text="RESONANCE  %d / 7"%value

func log_message(text_value:String,color:=Color(.55,.8,.86)) -> void:
    var item:=_label(text_value,12,color);log_container.add_child(item)
    if log_container.get_child_count()>5:log_container.get_child(0).queue_free()
    var tween:=create_tween();tween.tween_interval(6.0);tween.tween_property(item,"modulate:a",0.0,1.0);tween.tween_callback(item.queue_free)

func transition(caption:String,midpoint:Callable) -> void:
    prompt_label.text=caption
    var tween:=create_tween();tween.tween_property(fade,"color:a",1.0,.8);tween.tween_callback(midpoint);tween.tween_interval(.35);tween.tween_property(fade,"color:a",0.0,1.0)

func toggle_archive() -> void:
    archive_panel.visible=not archive_panel.visible;map_panel.visible=false

func toggle_map() -> void:
    map_panel.visible=not map_panel.visible;archive_panel.visible=false
