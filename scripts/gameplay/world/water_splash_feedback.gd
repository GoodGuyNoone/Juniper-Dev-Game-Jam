class_name WaterSplashFeedback
extends Node3D

enum Mode {
	IDLE,
	BITE,
	HOOKED,
}

@export var water_y: float = 0.03
@export var idle_amount: int = 1
@export var bite_amount: int = 4
@export var hooked_amount: int = 8
@export var idle_lifetime: float = 0.8
@export var bite_lifetime: float = 1.0
@export var hooked_lifetime: float = 0.5

var follow_target: Node3D = null


@onready var splash: GPUParticles3D = %Splash


func _ready() -> void:
	stop()


func start(mode: int = Mode.HOOKED) -> void:
	follow_target = null
	set_process(false)
	_start(mode)


func start_at(world_position: Vector3, mode: int = Mode.HOOKED) -> void:
	follow_target = null
	global_position = _get_water_position(world_position)
	_start(mode)


func start_follow(target: Node3D, mode: int = Mode.HOOKED) -> void:
	follow_target = target
	_update_follow_position()
	_start(mode)
	set_process(true)


func stop() -> void:
	follow_target = null
	hide()
	set_process(false)

	if splash != null:
		splash.emitting = false


func _process(_delta: float) -> void:
	if follow_target == null or not is_instance_valid(follow_target):
		stop()
		return

	_update_follow_position()


func _start(mode: int) -> void:
	_apply_mode(mode)
	show()

	if splash != null:
		splash.emitting = false
		splash.restart()
		splash.emitting = true


func _apply_mode(mode: int) -> void:
	if splash == null:
		return

	match mode:
		Mode.IDLE:
			splash.amount = idle_amount
			splash.lifetime = idle_lifetime
		Mode.BITE:
			splash.amount = bite_amount
			splash.lifetime = bite_lifetime
		Mode.HOOKED:
			splash.amount = hooked_amount
			splash.lifetime = hooked_lifetime

	splash.one_shot = false


func _update_follow_position() -> void:
	if follow_target == null or not is_instance_valid(follow_target):
		return

	global_position = _get_water_position(follow_target.global_position)


func _get_water_position(world_position: Vector3) -> Vector3:
	return Vector3(world_position.x, water_y, world_position.z)
