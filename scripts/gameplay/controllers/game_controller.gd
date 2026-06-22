class_name GameController
extends Node

signal catch_finished

@export var fish_coordinator: FishCoordinator
@export var timing_bar_mini_game: TimingBarMiniGame
@export var reel_spin_mini_game: ReelSpinMiniGame

var is_catching = false
var player_score := 0.0


func _ready() -> void:
	fish_coordinator.fish_bitten.connect(_on_fish_bitten)


func _on_fish_bitten(fish: Fish) -> void:
	if is_catching:
		fish.release()
		return

	is_catching = true

	print("Fish bitten: %s %.2f kg" % [fish.fish_type, fish.weight])
	timing_bar_mini_game.start()
	var hook_success: bool = await timing_bar_mini_game.completed
	print("Game ended: %s" % hook_success)

	if not hook_success:
		fish.release()
		_end_catch()
		return

	reel_spin_mini_game.start()
	var reel_success: bool = await reel_spin_mini_game.completed

	if not reel_success:
		fish.release()
		_end_catch()
		return

	player_score += fish.weight
	fish.queue_free()
	_end_catch()


func _end_catch() -> void:
	is_catching = false
	catch_finished.emit()
