class_name ScoreBoardPanel
extends VBoxContainer

@export var score_board_controller: ScoreBoardController
@export var row_scene: PackedScene

@onready var rows_container: VBoxContainer = %RowsContainer


func _ready() -> void:
	score_board_controller.standings_changed.connect(_refresh)
	_refresh(score_board_controller.get_standings())


func _refresh(standings: Array[Dictionary]) -> void:
	for child in rows_container.get_children():
		child.queue_free()

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
