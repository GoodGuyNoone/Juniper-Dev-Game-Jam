class_name FishCoordinator
extends Node

signal fish_bitten(fish: Fish)

@export var fish_scene: PackedScene
@export var fish_container: Node3D
@export var audio_controller: AudioController

@export_group("Spawn Area")
@export var spawn_center: Vector3 = Vector3.ZERO
@export var spawn_size: Vector2 = Vector2(14.0, 14.0)
@export var spawn_y: float = -0.15
@export var swim_edge_padding: float = 0.4
@export var buoy_attraction_radius: float = 4.0
@export var max_interested_fish: int = 3

@export_group("Small Fish")
@export var small_fish_respawn_time: float = 5.0
@export var small_fish_count: int = 8
@export var small_weight_range: Vector2 = Vector2(0.2, 0.9)
@export var small_wander_speed: float = 1.0
@export var small_chase_speed: float = 1.6
@export var small_wander_radius: float = 2.4

@export_group("Medium Fish")
@export var medium_fish_respawn_time: float = 10.0
@export var medium_fish_count: int = 4
@export var medium_weight_range: Vector2 = Vector2(1.0, 2.4)
@export var medium_wander_speed: float = 0.8
@export var medium_chase_speed: float = 1.3
@export var medium_wander_radius: float = 3.0

@export_group("Large Fish")
@export var large_fish_respawn_time: float = 15.0
@export var large_fish_count: int = 2
@export var large_weight_range: Vector2 = Vector2(2.5, 5.0)
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


func find_available_fish_in_radius(position: Vector3, radius: float) -> Array[Fish]:
	var result: Array[Fish] = []
	var radius_sq := radius * radius

	for fish in fishes:
		if not is_instance_valid(fish):
			continue
		if not fish.is_available:
			continue

		var distance_sq := fish.global_position.distance_squared_to(position)
		if distance_sq <= radius_sq:
			result.append(fish)

	result.sort_custom(func(a: Fish, b: Fish):
		return a.global_position.distance_squared_to(position) < b.global_position.distance_squared_to(position))

	return result


func send_fish_to_buoy(buoy: Buoy) -> Array[Fish]:
	var interested_fish := find_available_fish_in_radius(buoy.global_position, buoy_attraction_radius)

	if interested_fish.is_empty():
		return []

	interested_fish = interested_fish.slice(0, max_interested_fish)

	if audio_controller != null:
		audio_controller.play_fish_notice()

	for fish in interested_fish:
		fish.interest_in_buoy(buoy)
	return interested_fish


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
			config["wander_speed"],
			config["chase_speed"],
			config["wander_radius"],
			config["respawn_time"],
			spawn_center,
			spawn_size,
			spawn_y,
			swim_edge_padding
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
	_release_other_fish_targeting_buoy(fish.target_buoy, fish)
	fish_bitten.emit(fish)


func _release_other_fish_targeting_buoy(buoy: Node3D, biting_fish: Fish) -> void:
	if buoy == null:
		return

	for fish in fishes:
		if not is_instance_valid(fish):
			continue
		if fish == biting_fish:
			continue
		if fish.target_buoy != buoy:
			continue

		fish.release()


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
				"wander_speed": small_wander_speed,
				"chase_speed": small_chase_speed,
				"wander_radius": small_wander_radius,
				"respawn_time": small_fish_respawn_time
			}
		&"medium":
			return {
				"weight_range": medium_weight_range,
				"wander_speed": medium_wander_speed,
				"chase_speed": medium_chase_speed,
				"wander_radius": medium_wander_radius,
				"respawn_time": medium_fish_respawn_time
			}
		&"large":
			return {
				"weight_range": large_weight_range,
				"wander_speed": large_wander_speed,
				"chase_speed": large_chase_speed,
				"wander_radius": large_wander_radius,
				"respawn_time": large_fish_respawn_time
			}

	return {}
