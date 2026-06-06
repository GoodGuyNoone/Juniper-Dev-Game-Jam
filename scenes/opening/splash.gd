extends Control

@export_file("*.tscn") var next_scene_path: String
@export_range(0.1, 10.0, 0.1, "or_greater") var display_time: float = 2.0
@export_range(0.0, 2.0, 0.05) var fade_in_time: float = 0.25
@export_range(0.0, 2.0, 0.05) var fade_out_time: float = 0.25
@export var allow_skip: bool = true

var _changing_scene := false
var _logo_tween: Tween

@onready var logo_group: Control = %LogoGroup
@onready var logo_texture: TextureRect = %LogoTexture
@onready var placeholder_label: Label = %PlaceholderLabel

func _get_next_scene_path() -> String:
	if next_scene_path.is_empty():
		return AppConfig.main_menu_scene_path
	return next_scene_path

func _fade_logo(target_alpha: float, duration: float) -> void:
	if _logo_tween and _logo_tween.is_running():
		_logo_tween.kill()
	if is_zero_approx(duration):
		logo_group.modulate.a = target_alpha
		return
	_logo_tween = create_tween()
	_logo_tween.tween_property(logo_group, "modulate:a", target_alpha, duration)
	await _logo_tween.finished

func _load_next_scene() -> void:
	if _changing_scene:
		return
	_changing_scene = true
	await _fade_logo(0.0, fade_out_time)
	SceneLoader.load_scene(_get_next_scene_path())

func _ready() -> void:
	placeholder_label.visible = logo_texture.texture == null
	logo_group.modulate.a = 0.0
	await _fade_logo(1.0, fade_in_time)
	await get_tree().create_timer(display_time).timeout
	_load_next_scene()

func _unhandled_input(event: InputEvent) -> void:
	if not allow_skip:
		return
	if event.is_action_released(&"ui_accept") or event.is_action_released(&"ui_cancel"):
		_load_next_scene()
