class_name FishCoordinator
extends Node

signal fish_bitten(fish: Fish)

@export var fish_scene: PackedScene
@export var fish_container: Node3D

@export_group("Spawn Area")
@export var spawn_center: Vector3 = Vector3.ZERO
@export var spawn_size: Vector2 = Vector2(14.0, 14.0)
@export var spawn_y: float = -0.15

@export_group("Small Fish")
@export var small_fish_respawn_time: float = 5.0
@export var small_fish_count: int = 8
@export var small_weight_range: Vector2 = Vector2(0.2, 0.9)
@export var small_visual_scale: float = 0.7
@export var small_wander_speed: float = 1.0
@export var small_chase_speed: float = 1.6
@export var small_wander_radius: float = 2.4

@export_group("Medium Fish")
@export var medium_fish_respawn_time: float = 10.0
@export var medium_fish_count: int = 4
@export var medium_weight_range: Vector2 = Vector2(1.0, 2.4)
@export var medium_visual_scale: float = 1.0
@export var medium_wander_speed: float = 0.8
@export var medium_chase_speed: float = 1.3
@export var medium_wander_radius: float = 3.0

@export_group("Large Fish")
@export var large_fish_respawn_time: float = 15.0
@export var large_fish_count: int = 2
@export var large_weight_range: Vector2 = Vector2(2.5, 5.0)
@export var large_visual_scale: float = 1.4
@export var large_wander_speed: float = 0.55
@export var large_chase_speed: float = 1.0
@export var large_wander_radius: float = 3.8

var fishes: Array[Fish] = []
var rng := RandomNumberGenerator.new()


func _ready() -> void:
	rng.randomize()
	spawn_fish()


func spawn_fish() -> void:
	if fish_scene == null:
		push_warning("FishCoordinator has no fish scene assigned.")
		return
	if fish_container == null:
		push_warning("FishCoordinator has no fish container assigned.")
		return

	_spawn_fish_type(&"small", small_fish_count)
	_spawn_fish_type(&"medium", medium_fish_count)
	_spawn_fish_type(&"large", large_fish_count)


func find_closest_available_fish(position: Vector3) -> Fish:
	var closest_fish: Fish = null
	var closest_distance_sq := INF

	for fish in fishes:
		if not is_instance_valid(fish):
			continue
		if not fish.is_available:
			continue

		var distance_sq := fish.global_position.distance_squared_to(position)
		if distance_sq < closest_distance_sq:
			closest_distance_sq = distance_sq
			closest_fish = fish

	return closest_fish


func send_fish_to_buoy(buoy: Buoy) -> Fish:
	var fish := find_closest_available_fish(buoy.global_position)
	if fish == null:
		return null

	fish.interest_in_buoy(buoy)
	return fish


func _spawn_fish_type(fish_type: StringName, count: int) -> void:
	var config := _get_fish_config(fish_type)
	if config.is_empty():
		push_warning("Unknown fish type: %s" % fish_type)
		return

	for i in range(count):
		var fish := fish_scene.instantiate() as Fish
		var weight_range: Vector2 = config["weight_range"]

		if fish == null:
			push_warning("Fish scene root must use Fish script.")
			return

		fish.configure(
			fish_type,
			rng.randf_range(weight_range.x, weight_range.y),
			config["visual_scale"],
			config["wander_speed"],
			config["chase_speed"],
			config["wander_radius"],
			config["respawn_time"]
		)

		fish_container.add_child(fish)
		fish.global_position = _get_random_spawn_position()
		fish.initialize_spawn()
		fish.bitten.connect(_on_fish_bitten)
		fishes.append(fish)


func _get_random_spawn_position() -> Vector3:
	var half_size := spawn_size * 0.5

	return Vector3(
		spawn_center.x + rng.randf_range(-half_size.x, half_size.x),
		spawn_y,
		spawn_center.z + rng.randf_range(-half_size.y, half_size.y)
	)


func _on_fish_bitten(fish: Fish) -> void:
	fish_bitten.emit(fish)


func remove_and_respawn_fish(fish: Fish) -> void:
	var fish_type := fish.fish_type
	var respawn_time := fish.respawn_time

	fishes.erase(fish)
	fish.queue_free()

	await get_tree().create_timer(respawn_time).timeout

	if not is_inside_tree():
		return

	_spawn_fish_type(fish_type, 1)


func _get_fish_config(fish_type: StringName) -> Dictionary:
	match fish_type:
		&"small":
			return {
				"weight_range": small_weight_range,
				"visual_scale": small_visual_scale,
				"wander_speed": small_wander_speed,
				"chase_speed": small_chase_speed,
				"wander_radius": small_wander_radius,
				"respawn_time": small_fish_respawn_time
			}
		&"medium":
			return {
				"weight_range": medium_weight_range,
				"visual_scale": medium_visual_scale,
				"wander_speed": medium_wander_speed,
				"chase_speed": medium_chase_speed,
				"wander_radius": medium_wander_radius,
				"respawn_time": medium_fish_respawn_time
			}
		&"large":
			return {
				"weight_range": large_weight_range,
				"visual_scale": large_visual_scale,
				"wander_speed": large_wander_speed,
				"chase_speed": large_chase_speed,
				"wander_radius": large_wander_radius,
				"respawn_time": large_fish_respawn_time
			}

	return {}