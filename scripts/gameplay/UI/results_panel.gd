class_name ResultsPanel
extends PanelContainer

@export var score_board_controller: ScoreBoardController
@export var row_scene: PackedScene
@export var audio_controller: AudioController

@onready var rows_container: VBoxContainer = %RowsContainer
@onready var restart_button: Button = %RestartButton
@onready var menu_button: Button = %MenuButton


func _ready() -> void:
	hide()

	restart_button.pressed.connect(_on_restart_pressed)
	menu_button.pressed.connect(_on_menu_pressed)

	if score_board_controller == null:
		push_warning("ResultsPanel has no ScoreBoardController assigned.")
		return
	if row_scene == null:
		push_warning("ResultsPanel has no row scene assigned.")
		return

	score_board_controller.final_standings_ready.connect(_show_results)


func _show_results(standings: Array[Dictionary]) -> void:
	_clear_rows()

	for i in range(standings.size()):
		var entry := standings[i]
		var row := row_scene.instantiate() as ScoreBoardRow

		rows_container.add_child(row)
		row.set_score_row(
			i + 1,
			String(entry["name"]),
			float(entry["score"]),
			bool(entry["is_player"])
		)

	show()
	restart_button.grab_focus()


func _clear_rows() -> void:
	for child in rows_container.get_children():
		child.queue_free()


func _on_restart_pressed() -> void:
	if audio_controller != null:
		audio_controller.play_button_click()

	get_tree().reload_current_scene()


func _on_menu_pressed() -> void:
	if audio_controller != null:
		audio_controller.play_button_click()

	SceneLoader.load_scene(AppConfig.main_menu_scene_path)
