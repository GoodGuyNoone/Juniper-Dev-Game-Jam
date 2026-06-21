class_name GameController
extends Node


@export var fish_coordinator: FishCoordinator


func _ready() -> void:
	fish_coordinator.fish_bitten.connect(_on_fish_bitten)


func _on_fish_bitten(fish: Fish) -> void:
	print("Fish bitten: %s %.2f kg" % [fish.fish_type, fish.weight])
