class_name Buoy
extends Node3D

signal landed(buoy: Buoy)
signal retrieved(buoy: Buoy)

@export var bob_height: float = 0.1
@export var bob_speed: float = 2

var is_casted: bool = false
var _base_visuals_y := 0.0
var _time_passed := 0.0

@onready var visuals: Node3D = %Visuals
@onready var water_splash: WaterSplashFeedback = %WaterSplash


func _process(delta: float) -> void:
	if not is_casted:
		return
	
	_time_passed += delta
	visuals.position.y = _base_visuals_y + sin(_time_passed * bob_speed) * bob_height


func land_at(world_position: Vector3) -> void:
	global_position = world_position
	_base_visuals_y = visuals.position.y
	is_casted = true
	visible = true
	stop_splash()
	landed.emit(self)
	_time_passed = 0.0


func retrieve() -> void:
	if not is_casted:
		return

	is_casted = false
	stop_splash()
	retrieved.emit(self)
	queue_free()


func start_bite_splash() -> void:
	if water_splash == null:
		return

	water_splash.start(WaterSplashFeedback.Mode.BITE)


func start_hooked_splash() -> void:
	if water_splash == null:
		return

	water_splash.start(WaterSplashFeedback.Mode.HOOKED)


func stop_splash() -> void:
	if water_splash == null:
		return

	water_splash.stop()

