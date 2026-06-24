class_name GameController
extends Node

signal catch_finished
signal score_changed(score: float)
signal match_time_changed(time_left: float)
signal match_finished
signal line_recovery_started(duration: float)
signal line_recovery_finished

@export var fish_coordinator: FishCoordinator
@export var hook_reaction_mini_game: HookReactionMiniGame
@export var timing_bar_mini_game: TimingBarMiniGame
@export var reel_spin_mini_game: ReelSpinMiniGame
@export var match_duration: float = 300.0
@export var line_recovery_duration: float = 2.0

var is_catching := false
var is_match_running := false
var is_recovering_line := false
var player_score := 0.0
var time_left := 0.0
var active_catch_buoy: Buoy = null


func _ready() -> void:
	if fish_coordinator == null:
		push_error("GameController has no FishCoordinator assigned.")
	else:
		fish_coordinator.fish_bitten.connect(_on_fish_bitten)

	if hook_reaction_mini_game == null:
		push_error("GameController has no HookReactionMiniGame assigned.")

	call_deferred("_start_match")


func _process(delta: float) -> void:
	if not is_match_running:
		return

	time_left = maxf(0.0, time_left - delta)
	match_time_changed.emit(time_left)

	if time_left <= 0.0:
		_finish_match()


func _on_fish_bitten(fish: Fish) -> void:
	if not is_match_running:
		fish.release()
		return

	if is_catching:
		fish.release()
		return

	is_catching = true
	active_catch_buoy = fish.target_buoy as Buoy

	print("Fish bitten: %s %.2f kg" % [fish.fish_type, fish.weight])
	_start_bite_splash()

	if hook_reaction_mini_game != null:
		hook_reaction_mini_game.start()
		var reaction_success: bool = await hook_reaction_mini_game.completed

		if not is_match_running:
			fish.release()
			_end_catch()
			return

		if not reaction_success:
			fish.release()
			_start_line_recovery()
			_end_catch()
			return

	_start_hooked_splash()

	timing_bar_mini_game.start()
	var hook_success: bool = await timing_bar_mini_game.completed
	print("Game ended: %s" % hook_success)

	if not is_match_running:
		fish.release()
		_end_catch()
		return

	if not hook_success:
		fish.release()
		_start_line_recovery()
		_end_catch()
		return

	reel_spin_mini_game.start()
	var reel_success: bool = await reel_spin_mini_game.completed

	if not is_match_running:
		fish.release()
		_end_catch()
		return

	if not reel_success:
		fish.release()
		_start_line_recovery()
		_end_catch()
		return

	player_score += fish.weight
	score_changed.emit(player_score)

	fish_coordinator.remove_and_respawn_fish(fish)
	_end_catch()


func _end_catch() -> void:
	_stop_active_buoy_splash()
	active_catch_buoy = null
	is_catching = false
	catch_finished.emit()


func _start_bite_splash() -> void:
	if active_catch_buoy == null or not is_instance_valid(active_catch_buoy):
		return

	active_catch_buoy.start_bite_splash()


func _start_hooked_splash() -> void:
	if active_catch_buoy == null or not is_instance_valid(active_catch_buoy):
		return

	active_catch_buoy.start_hooked_splash()


func _stop_active_buoy_splash() -> void:
	if active_catch_buoy == null or not is_instance_valid(active_catch_buoy):
		return

	active_catch_buoy.stop_splash()


func _start_line_recovery() -> void:
	if not is_match_running:
		return
	if is_recovering_line:
		return

	is_recovering_line = true
	line_recovery_started.emit(line_recovery_duration)


func complete_line_recovery() -> void:
	if not is_recovering_line:
		return

	is_recovering_line = false
	line_recovery_finished.emit()


func _start_match() -> void:
	print("match started")
	is_match_running = true
	is_catching = false
	is_recovering_line = false
	player_score = 0.0
	time_left = match_duration

	score_changed.emit(player_score)
	match_time_changed.emit(time_left)


func _finish_match() -> void:
	if not is_match_running:
		return

	is_match_running = false
	complete_line_recovery()
	time_left = 0.0
	_stop_active_buoy_splash()
	if hook_reaction_mini_game != null:
		hook_reaction_mini_game.cancel()
	timing_bar_mini_game.cancel()
	reel_spin_mini_game.cancel()
	match_time_changed.emit(time_left)
	match_finished.emit()
