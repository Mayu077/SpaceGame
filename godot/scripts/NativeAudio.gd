class_name NativeAudio
extends Node

var player: AudioStreamPlayer
var playback: AudioStreamGeneratorPlayback
var phase_low := 0.0
var phase_engine := 0.0
var phase_pulse := 0.0
var engine_level := 0.0
var scan_level := 0.0
var surface_mix := 0.0
var rng := RandomNumberGenerator.new()
const MIX_RATE := 44100.0

func _ready() -> void:
    rng.seed=72817
    var generator:=AudioStreamGenerator.new()
    generator.mix_rate=MIX_RATE
    generator.buffer_length=.45
    player=AudioStreamPlayer.new()
    player.stream=generator
    player.volume_db=-15.0
    add_child(player)
    player.play()
    playback=player.get_stream_playback() as AudioStreamGeneratorPlayback

func set_engine(speed:float) -> void:
    engine_level=clamp(speed/155.0,0.0,1.0)

func set_scanning(active:bool) -> void:
    scan_level=move_toward(scan_level,1.0 if active else 0.0,.08)

func set_surface(active:bool) -> void:
    surface_mix=1.0 if active else 0.0

func _process(_delta:float) -> void:
    if not playback:return
    var frames:=playback.get_frames_available()
    for index in frames:
        var low_frequency:=34.0+engine_level*8.0
        var engine_frequency:=68.0+engine_level*94.0
        phase_low=fmod(phase_low+TAU*low_frequency/MIX_RATE,TAU)
        phase_engine=fmod(phase_engine+TAU*engine_frequency/MIX_RATE,TAU)
        phase_pulse=fmod(phase_pulse+TAU*(410.0+sin(phase_low)*34.0)/MIX_RATE,TAU)
        var hull_hum:=sin(phase_low)*.22+sin(phase_low*2.01)*.08+sin(phase_low*.503)*.05
        var engine:=((sin(phase_engine)+sin(phase_engine*1.997)*.38)/1.38)*engine_level*.26
        var scanner:=(sin(phase_pulse)*.12+sin(phase_pulse*1.502)*.04)*scan_level
        var wind:=rng.randf_range(-1.0,1.0)*.045*surface_mix
        var sample:=tanh(hull_hum*(1.0-surface_mix*.75)+engine+scanner+wind)
        playback.push_frame(Vector2(sample,sample*.985))
