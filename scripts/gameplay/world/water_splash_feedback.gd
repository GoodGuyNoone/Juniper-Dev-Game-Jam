class_name WaterSplashFeedback
extends Node3D

enum Mode {
	IDLE,
	BITE,
	HOOKED,
}

@export var water_y: float = 0.03
@export var idle_ripple_amount: int = 2
@export var bite_ripple_amount: int = 4
@export var hooked_ripple_amount: int = 4
@export var idle_lifetime: float = 0.8
@export var bite_lifetime: float = 1.0
@export var hooked_lifetime: float = 1.0

var follow_target: Node3D = null

@onready var ripple_particles: GPUParticles3D = %RippleParticles


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

	if ripple_particles != null:
		ripple_particles.visible = false
		ripple_particles.emitting = false


func _process(_delta: float) -> void:
	if follow_target == null or not is_instance_valid(follow_target):
		stop()
		return

	_update_follow_position()


func _start(mode: int) -> void:
	_apply_mode(mode)
	show()

	if ripple_particles != null:
		ripple_particles.visible = true
		ripple_particles.emitting = false
		ripple_particles.restart()
		ripple_particles.emitting = true


func _apply_mode(mode: int) -> void:
	match mode:
		Mode.IDLE:
			_apply_particle_settings(idle_ripple_amount, idle_lifetime)
		Mode.BITE:
			_apply_particle_settings(bite_ripple_amount, bite_lifetime)
		Mode.HOOKED:
			_apply_particle_settings(hooked_ripple_amount, hooked_lifetime)


func _apply_particle_settings( ripple_amount: int, particle_lifetime: float) -> void:
	if ripple_particles != null:
		ripple_particles.amount = ripple_amount
		ripple_particles.lifetime = particle_lifetime
		ripple_particles.one_shot = false


func _update_follow_position() -> void:
	if follow_target == null or not is_instance_valid(follow_target):
		return

	global_position = _get_water_position(follow_target.global_position)


func _get_water_position(world_position: Vector3) -> Vector3:
	return Vector3(world_position.x, water_y, world_position.z)
