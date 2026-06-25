class_name Fish
extends Node3D

signal bitten(fish: Fish)

enum State {
	WANDER,
	INTERESTED,
	BITE,
}

@export var wander_radius: float = 3.0
@export var bite_distance: float = 0.1
@export var wander_speed: float = 0.8
@export var chase_speed: float = 1.4
@export var turn_speed: float = 3.0
@export var fish_type: StringName = &"small"
@export var weight: float = 0.5
@export var respawn_time: float = 5.0
@export_group("Swim Area")
@export var swim_area_center: Vector3 = Vector3.ZERO
@export var swim_area_size: Vector2 = Vector2(14.0, 14.0)
@export var swim_y: float = -0.15
@export var swim_edge_padding: float = 0.4

var state := State.WANDER
var home_position: Vector3
var target_position: Vector3
var target_buoy: Node3D = null
var is_available: bool = true

var rng := RandomNumberGenerator.new()

@onready var visuals: Node3D = %Visuals
@onready var interest_marker: Node3D = %InterestMark


func _ready() -> void:
	rng.randomize()
	initialize_spawn()


func initialize_spawn() -> void:
	_apply_fish_visual()
	global_position = _get_swim_position(global_position)
	home_position = global_position
	_pick_wander_target()


func _process(delta: float) -> void:
	global_position = _get_swim_position(global_position)

	match state:
		State.WANDER:
			_process_wander(delta)

		State.INTERESTED:
			_process_interested(delta)

		State.BITE:
			pass


func configure(
	new_fish_type: StringName,
	new_weight: float,
	new_wander_speed: float,
	new_chase_speed: float,
	new_wander_radius: float,
	new_respawn_time: float,
	new_swim_area_center: Vector3 = Vector3.ZERO,
	new_swim_area_size: Vector2 = Vector2(14.0, 14.0),
	new_swim_y: float = -0.15,
	new_swim_edge_padding: float = 0.4
) -> void:
	fish_type = new_fish_type
	weight = new_weight
	wander_speed = new_wander_speed
	chase_speed = new_chase_speed
	wander_radius = new_wander_radius
	respawn_time = new_respawn_time
	swim_area_center = new_swim_area_center
	swim_area_size = new_swim_area_size
	swim_y = new_swim_y
	swim_edge_padding = new_swim_edge_padding

	_apply_fish_visual()


func interest_in_buoy(buoy: Node3D) -> void:
	if not is_available:
		return

	interest_marker.visible = true
	target_buoy = buoy
	is_available = false
	state = State.INTERESTED


func _pick_wander_target() -> void:
	var angle := rng.randf_range(0.0, TAU)
	var distance := rng.randf_range(0.0, wander_radius)
	var offset := Vector3(
		cos(angle) * distance,
		0.0,
		sin(angle) * distance,
	)
	target_position = _get_swim_position(home_position + offset)


func _process_wander(delta: float) -> void:
	_swim_toward(target_position, wander_speed, delta)

	if global_position.distance_to(target_position) <= 0.2:
		_pick_wander_target()


func _process_interested(delta: float) -> void:
	if target_buoy == null or not is_instance_valid(target_buoy):
		release()
		return

	var bite_target := _get_swim_position(target_buoy.global_position)
	var to_buoy := bite_target - global_position
	to_buoy.y = 0

	target_position = bite_target
	_swim_toward(target_position, chase_speed, delta)

	if to_buoy.length() <= bite_distance:
		_bite()


func _swim_toward(target: Vector3, speed: float, delta: float) -> void:
	var to_target := target - global_position
	to_target.y = 0.0

	if to_target.length() <= 0.01:
		return

	var direction := to_target.normalized()

	global_position += direction * speed * delta
	global_position = _get_swim_position(global_position)

	var desired_basis := Basis.looking_at(direction, Vector3.UP)

	var turn_weight := clampf(turn_speed * delta, 0.0, 1.0)
	global_basis = global_basis.slerp(desired_basis, turn_weight)


func release() -> void:
	interest_marker.visible = false
	target_buoy = null
	is_available = true
	state = State.WANDER
	_pick_wander_target()


func _apply_fish_visual() -> void:
	if visuals == null:
		return

	var active_visual_name := fish_type

	for child in visuals.get_children():
		if child is Node3D:
			child.visible = child.name == active_visual_name


func _bite() -> void:
	interest_marker.visible = false
	state = State.BITE
	bitten.emit(self)


func _get_swim_position(position: Vector3) -> Vector3:
	var half_x := maxf(0.0, swim_area_size.x * 0.5 - swim_edge_padding)
	var half_z := maxf(0.0, swim_area_size.y * 0.5 - swim_edge_padding)

	return Vector3(
		clampf(position.x, swim_area_center.x - half_x, swim_area_center.x + half_x),
		swim_y,
		clampf(position.z, swim_area_center.z - half_z, swim_area_center.z + half_z)
	)
