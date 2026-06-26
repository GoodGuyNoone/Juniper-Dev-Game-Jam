class_name MainMenu
extends Control
## Base menu scene that links to a game scene, an options menu, and credits.

signal sub_menu_opened
signal sub_menu_closed
signal game_started
signal game_exited

## Defines the path to the game scene. Hides the play button if empty.
## Will attempt to read from AppConfig if left empty.
@export_file("*.tscn") var game_scene_path : String
## The scene to open when a player clicks the 'Options' button.
@export var options_packed_scene : PackedScene
## The scene to open when a player clicks the 'Credits' button.
@export var credits_packed_scene : PackedScene
@export var confirm_exit : bool = true
@export var audio_controller : AudioController
@export_group("Extra Settings")
## If true, signals that the game has started loading in the background, instead of directly loading it.
@export var signal_game_start : bool = false
## If true, signals that the player clicked the 'Exit' button, instead of immediately exiting.
@export var signal_game_exit : bool = false

var sub_menu : Control

@onready var menu_container = %MenuContainer
@onready var menu_buttons_box_container = %MenuButtonsBoxContainer
@onready var new_game_button = %NewGameButton
@onready var options_button = %OptionsButton
@onready var credits_button = %CreditsButton
@onready var exit_button = %ExitButton
@onready var exit_confirmation = %ExitConfirmation

func _get_audio_controller() -> AudioController:
	if audio_controller == null:
		audio_controller = get_node_or_null("AudioController") as AudioController
	return audio_controller

func _play_button_sound() -> void:
	var controller := _get_audio_controller()
	if controller != null:
		controller.play_button_click()

func _connect_button_sounds(root: Node) -> void:
	if root == null:
		return
	if not root.child_entered_tree.is_connected(_on_menu_child_entered_tree):
		root.child_entered_tree.connect(_on_menu_child_entered_tree)
	if root is BaseButton:
		var button := root as BaseButton
		if not button.button_down.is_connected(_play_button_sound):
			button.button_down.connect(_play_button_sound)
	for child in root.get_children():
		_connect_button_sounds(child)

func _on_menu_child_entered_tree(child: Node) -> void:
	_connect_button_sounds(child)

func get_game_scene_path() -> String:
	if game_scene_path.is_empty():
		return AppConfig.game_scene_path
	return game_scene_path

func load_game_scene() -> void:
	if signal_game_start:
		SceneLoader.load_scene(get_game_scene_path(), true)
		game_started.emit()
	else:
		SceneLoader.load_scene(get_game_scene_path())

func _open_window(window : Node) -> void:
	if window.has_method("open"):
		window.call("open")
	elif window is CanvasItem:
		(window as CanvasItem).show()

func new_game() -> void:
	load_game_scene()

func try_exit_game() -> void:
	if confirm_exit and (not exit_confirmation.visible):
		_open_window(exit_confirmation)
	else:
		exit_game()

func exit_game() -> void:
	if OS.has_feature("web"):
		return
	if signal_game_exit:
		game_exited.emit()
	else:
		get_tree().quit()

func _open_sub_menu(menu : PackedScene) -> Node:
	sub_menu = menu.instantiate()
	add_child(sub_menu)
	_connect_button_sounds(sub_menu)
	menu_container.hide()
	sub_menu.hidden.connect(_close_sub_menu, CONNECT_ONE_SHOT)
	sub_menu.tree_exiting.connect(_close_sub_menu, CONNECT_ONE_SHOT)
	sub_menu_opened.emit()
	return sub_menu

func _close_sub_menu() -> void:
	if sub_menu == null:
		return
	sub_menu.queue_free()
	sub_menu = null
	menu_container.show()
	sub_menu_closed.emit()

func _event_is_mouse_button_released(event : InputEvent) -> bool:
	return event is InputEventMouseButton and not event.is_pressed()

func _input(event : InputEvent) -> void:
	if event.is_action_released("ui_cancel"):
		if sub_menu:
			_close_sub_menu()
		else:
			try_exit_game()
	if event.is_action_released("ui_accept") and get_viewport().gui_get_focus_owner() == null:
		menu_buttons_box_container.focus_first()

func _hide_exit_for_web() -> void:
	if OS.has_feature("web"):
		exit_button.hide()

func _hide_new_game_if_unset() -> void:
	if get_game_scene_path().is_empty():
		new_game_button.hide()

func _hide_options_if_unset() -> void:
	if options_packed_scene == null:
		options_button.hide()

func _hide_credits_if_unset() -> void:
	if credits_packed_scene == null:
		credits_button.hide()

func _ready() -> void:
	_hide_exit_for_web()
	_hide_options_if_unset()
	_hide_credits_if_unset()
	_hide_new_game_if_unset()
	_connect_button_sounds(self)
	var controller := _get_audio_controller()
	if controller != null:
		controller.start_music()

func _on_new_game_button_pressed() -> void:
	new_game()

func _on_options_button_pressed() -> void:
	_open_sub_menu(options_packed_scene)

func _on_credits_button_pressed() -> void:
	_open_sub_menu(credits_packed_scene)

func _on_exit_button_pressed() -> void:
	try_exit_game()

func _on_exit_confirmation_confirmed():
	exit_game()
