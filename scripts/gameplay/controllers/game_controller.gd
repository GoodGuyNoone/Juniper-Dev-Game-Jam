class_name GameController
extends Node


@export var fish_coordinator: FishCoordinator
@export var timing_bar_mini_game: TimingBarMiniGame


func _ready() -> void:
	fish_coordinator.fish_bitten.connect(_on_fish_bitten)


func _on_fish_bitten(fish: Fish) -> void:
	print("Fish bitten: %s %.2f kg" % [fish.fish_type, fish.weight])
	timing_bar_mini_game.start()
	var success: bool = await timing_bar_mini_game.completed
	print("Game ended: %s" % success)
