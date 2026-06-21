class_name Pool
extends Node3D

@export var water_pick_collision_mask: int = 1

const RAY_LENGTH = 1000.0

func get_mouse_water_position(camera: Camera3D, mouse_position: Vector2) -> Variant:
	var ray_origin := camera.project_ray_origin(mouse_position)
	var ray_direction := camera.project_ray_normal(mouse_position)
	var ray_end := ray_origin + ray_direction * RAY_LENGTH

	var query := PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
	query.collision_mask = water_pick_collision_mask
	query.collide_with_areas = false
	query.collide_with_bodies = true

	var result := get_world_3d().direct_space_state.intersect_ray(query)

	if result.is_empty():
		return null

	return result.position
