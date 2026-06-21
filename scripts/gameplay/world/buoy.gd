class_name Buoy
extends Node3D

signal landed(buoy: Buoy)
signal retrieved(buoy: Buoy)

@export var bob_height: float = 0.1
@export var bob_speed: float = 2

var is_casted: bool = false
var _base_y := 0.0
var _time_passed := 0.0

@onready var visual: Node3D = $Visual


func _process(delta: float) -> void:
	if not is_casted:
		return
	
	_time_passed += delta
	visual.position.y = _base_y + sin(_time_passed * bob_speed) * bob_height


func land_at(world_position: Vector3) -> void:
	global_position = world_position
	_base_y = global_position.y
	is_casted = true
	visible = true
	landed.emit(self)
	_time_passed = 0.0


func retrieve() -> void:
	if not is_casted:
		return

	is_casted = false
	retrieved.emit(self)
	queue_free()


