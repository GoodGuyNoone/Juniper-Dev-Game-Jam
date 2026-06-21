class_name RayCastMuseController
extends Node

@export var pool: Pool
@export var camera: Camera3D
@export var player_cursor: Node3D
@export var buoy_scene: PackedScene 
@export var buoy_container: Node3D

var current_water_position: Variant = null

func _process(delta: float) -> void:
	var mouse_position := get_viewport().get_mouse_position()
	current_water_position = pool.get_mouse_water_position(camera, mouse_position)

	if current_water_position == null:
		player_cursor.visible = false
		return
	
	player_cursor.visible = true
	player_cursor.global_position = current_water_position


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			_try_cast()


func _try_cast() -> void:
	if current_water_position == null:
		return
	
	var buoy := buoy_scene.instantiate()
	buoy_container.add_child(buoy)
	buoy.global_position = current_water_position