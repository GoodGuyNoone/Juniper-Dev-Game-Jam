class_name AudioController
extends Node

@export_group("SFX")
@export var cast_whoosh: AudioStream
@export var buoy_splash_soft: AudioStream
@export var fish_notice: AudioStream
@export var fish_bite: AudioStream
@export var hook_success: AudioStream
@export var hook_fail: AudioStream
@export var catch_success: AudioStream
@export var line_break: AudioStream
@export var line_repaired: AudioStream
@export var countdown_tick: AudioStream
@export var countdown_go: AudioStream
@export var match_end_whistle: AudioStream
@export var button_click: AudioStream

@export_group("Loops")
@export var reel_tick_loop: AudioStream
@export var pond_ambience_loop: AudioStream
@export var music_loop: AudioStream

@export_group("Mixer")
@export var sfx_bus: StringName = &"Master"
@export var ambience_bus: StringName = &"Master"
@export var music_bus: StringName = &"Master"
@export var sfx_volume_db: float = 0.0
@export var ambience_volume_db: float = -12.0
@export var music_volume_db: float = -10.0


func play_cast_whoosh() -> void:
	_play_one_shot(cast_whoosh)


func play_buoy_splash_soft() -> void:
	_play_one_shot(buoy_splash_soft)


func play_fish_notice() -> void:
	_play_one_shot(fish_notice)


func play_fish_bite() -> void:
	_play_one_shot(fish_bite)


func play_hook_success() -> void:
	_play_one_shot(hook_success)


func play_hook_fail() -> void:
	_play_one_shot(hook_fail)


func play_catch_success() -> void:
	_play_one_shot(catch_success)


func play_line_break() -> void:
	_play_one_shot(line_break)


func play_line_repaired() -> void:
	_play_one_shot(line_repaired)


func play_countdown_tick() -> void:
	_play_one_shot(countdown_tick)


func play_countdown_go() -> void:
	_play_one_shot(countdown_go)


func play_match_end_whistle() -> void:
	_play_one_shot(match_end_whistle)


func play_button_click() -> void:
	_play_one_shot(button_click)


func start_reel_tick_loop() -> void:
	_play_loop(&"ReelTickPlayer", reel_tick_loop, sfx_bus, sfx_volume_db)


func stop_reel_tick_loop() -> void:
	_stop_loop(&"ReelTickPlayer")


func start_pond_ambience() -> void:
	_play_loop(&"PondAmbiencePlayer", pond_ambience_loop, ambience_bus, ambience_volume_db)


func stop_pond_ambience() -> void:
	_stop_loop(&"PondAmbiencePlayer")


func start_music() -> void:
	_play_loop(&"MusicPlayer", music_loop, music_bus, music_volume_db)


func stop_music() -> void:
	_stop_loop(&"MusicPlayer")


func _play_one_shot(stream: AudioStream) -> void:
	if stream == null:
		return

	var player := AudioStreamPlayer.new()
	add_child(player)
	player.stream = stream
	player.bus = String(sfx_bus)
	player.volume_db = sfx_volume_db
	player.finished.connect(player.queue_free)
	player.play()


func _play_loop(player_name: StringName, stream: AudioStream, bus_name: StringName, volume_db: float) -> void:
	if stream == null:
		return

	var player := _get_or_create_loop_player(player_name)
	player.stream = stream
	player.bus = String(bus_name)
	player.volume_db = volume_db
	if not player.finished.is_connected(player.play):
		player.finished.connect(player.play)

	if not player.playing:
		player.play()


func _stop_loop(player_name: StringName) -> void:
	var player := get_node_or_null(NodePath(String(player_name))) as AudioStreamPlayer
	if player == null:
		return

	player.stop()


func _get_or_create_loop_player(player_name: StringName) -> AudioStreamPlayer:
	var player := get_node_or_null(NodePath(String(player_name))) as AudioStreamPlayer
	if player != null:
		return player

	player = AudioStreamPlayer.new()
	player.name = String(player_name)
	add_child(player)
	return player
