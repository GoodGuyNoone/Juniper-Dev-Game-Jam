class_name GameHUD
extends Control

@export var game_controller: GameController

@onready var timer_label: Label = $TimerLabel 
@onready var score_label: Label = $ScoreLabel


func _ready() -> void:
	if game_controller == null:
		return

	game_controller.match_time_changed.connect(_on_match_time_changed)
	game_controller.score_changed.connect(_on_score_changed)


func _on_match_time_changed(time_left: float) -> void:
	timer_label.text = _format_sports_clock(time_left)


func _on_score_changed(score: float) -> void:
	print("change score to: %f" % score)
	score_label.text = "%.2f kg" % score


func _format_sports_clock(time_left: float) -> String:
	var total_seconds: int = maxi(0, int(ceil(time_left)))
	var minutes: int = floori(total_seconds / 60.0)
	var seconds: int = total_seconds % 60

	return "%02d:%02d" % [minutes, seconds]

