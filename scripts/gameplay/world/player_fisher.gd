class_name PlayerFisher
extends Node3D

@export var animation_player: AnimationPlayer

@export_group("Animation Names")
@export var idle_animation: StringName = &"Idle"
@export var cast_animation: StringName = &"Throwing"
@export var reel_animation: StringName = &"Twists"

var _return_to_idle_after_current := false


func _ready() -> void:
	if animation_player == null:
		animation_player = get_node_or_null("AnimationPlayer") as AnimationPlayer

	if animation_player == null:
		push_warning("PlayerFisher has no AnimationPlayer assigned.")
		return

	if not animation_player.animation_finished.is_connected(_on_animation_finished):
		animation_player.animation_finished.connect(_on_animation_finished)

	play_idle()


func play_idle() -> void:
	_return_to_idle_after_current = false
	_play_animation(idle_animation, false)


func play_cast() -> void:
	_play_animation(cast_animation, true)


func play_reel() -> void:
	_return_to_idle_after_current = false
	_play_animation(reel_animation, false)


func _play_animation(animation_name: StringName, return_to_idle: bool) -> void:
	if animation_player == null:
		return
	if animation_name == &"":
		return

	_return_to_idle_after_current = return_to_idle
	if animation_player.current_animation == animation_name and animation_player.is_playing():
		return

	animation_player.play(animation_name)


func _on_animation_finished(animation_name: StringName) -> void:
	if not _return_to_idle_after_current:
		return
	if animation_name == idle_animation:
		return

	play_idle()
