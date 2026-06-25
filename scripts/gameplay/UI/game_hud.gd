class_name GameHUD
extends Control

@export var game_controller: GameController
@export var countdown_steps: PackedStringArray = ["3", "2", "1", "GO"]
@export var countdown_step_duration: float = 0.75
@export var hud_slide_duration: float = 0.45

@onready var timer_label: Label = %TimerLabel
@onready var score_label: Label = %ScoreLabel
@onready var countdown_label: Label = %CountdownLabel
@onready var timer_panel: Control = %TimerPanel as Control
@onready var scoreboard_panel: Control = %ScoreBoardPanel as Control

var timer_final_position := Vector2.ZERO
var scoreboard_final_position := Vector2.ZERO


func _ready() -> void:
	if game_controller != null:
		game_controller.match_time_changed.connect(_on_match_time_changed)
		game_controller.score_changed.connect(_on_score_changed)


func play_start_sequence() -> void:
	await get_tree().process_frame

	_cache_hud_positions()
	_hide_match_hud()
	await _play_countdown()
	await _show_match_hud()


func _on_match_time_changed(time_left: float) -> void:
	timer_label.text = _format_sports_clock(time_left)


func _on_score_changed(score: float) -> void:
	print("change score to: %f" % score)
	score_label.text = "%.2f kg" % score


func _cache_hud_positions() -> void:
	if timer_panel != null:
		timer_final_position = timer_panel.position
	if scoreboard_panel != null:
		scoreboard_final_position = scoreboard_panel.position


func _hide_match_hud() -> void:
	if timer_panel != null:
		timer_panel.visible = false
	if scoreboard_panel != null:
		scoreboard_panel.visible = false


func _play_countdown() -> void:
	if countdown_label == null:
		return

	countdown_label.visible = true

	for countdown_text in countdown_steps:
		countdown_label.text = countdown_text
		countdown_label.scale = Vector2.ONE * 1.6
		countdown_label.modulate.a = 1.0

		var tween := create_tween()
		tween.set_trans(Tween.TRANS_BACK)
		tween.set_ease(Tween.EASE_OUT)
		tween.tween_property(countdown_label, "scale", Vector2.ONE, 0.25)
		tween.parallel().tween_property(countdown_label, "modulate:a", 0.0, countdown_step_duration)
		await tween.finished

	countdown_label.visible = false


func _show_match_hud() -> void:
	var viewport_size := get_viewport_rect().size
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_OUT)

	if timer_panel != null:
		timer_panel.position = Vector2(timer_final_position.x, -timer_panel.size.y - 20.0)
		timer_panel.visible = true
		tween.tween_property(timer_panel, "position", timer_final_position, hud_slide_duration)

	if scoreboard_panel != null:
		scoreboard_panel.position = Vector2(viewport_size.x + 20.0, scoreboard_final_position.y)
		scoreboard_panel.visible = true
		tween.parallel().tween_property(scoreboard_panel, "position", scoreboard_final_position, hud_slide_duration)

	await tween.finished


func _format_sports_clock(time_left: float) -> String:
	var total_seconds: int = maxi(0, int(ceil(time_left)))
	var minutes: int = floori(total_seconds / 60.0)
	var seconds: int = total_seconds % 60

	return "%02d:%02d" % [minutes, seconds]
