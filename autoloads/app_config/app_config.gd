extends Node

const DEFAULT_PLAYER_NAME := "Player"
const MAX_PLAYER_NAME_LENGTH := 16

@export_group("Scenes")
@export_file("*.tscn") var main_menu_scene_path : String
@export_file("*.tscn") var game_scene_path : String
@export_file("*.tscn") var ending_scene_path : String
@export_group("Player")
@export var player_name : String = DEFAULT_PLAYER_NAME

func _clean_player_name(value: String) -> String:
	var cleaned := value.strip_edges()
	if cleaned.is_empty():
		return DEFAULT_PLAYER_NAME
	if cleaned.length() > MAX_PLAYER_NAME_LENGTH:
		cleaned = cleaned.substr(0, MAX_PLAYER_NAME_LENGTH)
	return cleaned

func set_player_name(value: String) -> void:
	player_name = _clean_player_name(value)

func get_player_name() -> String:
	return _clean_player_name(player_name)

func get_max_player_name_length() -> int:
	return MAX_PLAYER_NAME_LENGTH

func _ready() -> void:
	GlobalState.open()
	AppSettings.set_from_config_and_window(get_window())
