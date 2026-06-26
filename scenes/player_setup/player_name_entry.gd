extends Control

@export_file("*.tscn") var next_scene_path: String

@onready var name_line_edit: LineEdit = %NameLineEdit
@onready var start_button: Button = %StartButton
@onready var back_button: Button = %BackButton

func _ready() -> void:
	name_line_edit.text = AppConfig.get_player_name()
	name_line_edit.max_length = AppConfig.get_max_player_name_length()
	name_line_edit.text_submitted.connect(_on_name_submitted)
	start_button.pressed.connect(_start_game)
	back_button.pressed.connect(_go_back)
	name_line_edit.grab_focus()
	name_line_edit.select_all()

func _get_next_scene_path() -> String:
	if next_scene_path.is_empty():
		return AppConfig.game_scene_path
	return next_scene_path

func _start_game() -> void:
	AppConfig.set_player_name(name_line_edit.text)
	SceneLoader.load_scene(_get_next_scene_path())

func _go_back() -> void:
	SceneLoader.load_scene(AppConfig.main_menu_scene_path)

func _on_name_submitted(_new_text: String) -> void:
	_start_game()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_released(&"ui_cancel"):
		_go_back()
