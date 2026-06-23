class_name RayCastMouseController
extends Node

@export var pool: Pool
@export var camera: Camera3D
@export var player_cursor: Node3D
@export var buoy_scene: PackedScene 
@export var buoy_container: Node3D
@export var fish_coordinator: FishCoordinator
@export var timing_bar_mini_game: TimingBarMiniGame
@export var game_controller: GameController

var current_water_position: Variant = null
var active_buoy: Buoy = null


func _ready() -> void:
	if game_controller != null:
		game_controller.catch_finished.connect(retrieve_active_buoy)
		game_controller.match_finished.connect(retrieve_active_buoy)


func _process(_delta: float) -> void:
	if _is_water_input_blocked():
		current_water_position = null
		player_cursor.visible = false
		return

	var mouse_position := get_viewport().get_mouse_position()
	current_water_position = pool.get_mouse_water_position(camera, mouse_position)

	if current_water_position == null:
		player_cursor.visible = false
		return
	
	player_cursor.visible = true
	player_cursor.global_position = current_water_position


func _unhandled_input(event: InputEvent) -> void:
	if _is_water_input_blocked():
		return

	if event is not InputEventMouseButton:
		return
	if not event.is_pressed():
		return
	
	if event.button_index == MOUSE_BUTTON_LEFT:
		_try_cast()

	if event.button_index == MOUSE_BUTTON_RIGHT:
		retrieve_active_buoy()


func _try_cast() -> void:
	if current_water_position == null:
		return
	
	retrieve_active_buoy()

	var buoy := buoy_scene.instantiate() as Buoy
	buoy_container.add_child(buoy)
	buoy.land_at(current_water_position)

	active_buoy = buoy

	fish_coordinator.send_fish_to_buoy(buoy)


func retrieve_active_buoy() -> void:
	if active_buoy == null:
		return

	if is_instance_valid(active_buoy):
		active_buoy.retrieve()
	
	active_buoy = null


func _is_water_input_blocked() -> bool:
	if game_controller == null:
		return false

	return (
		game_controller.is_catching
		or game_controller.is_recovering_line
		or not game_controller.is_match_running
	)
