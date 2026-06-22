class_name ScoreBoardController
extends Node

signal standings_changed(standings: Array[Dictionary])
signal final_standings_ready(standings: Array[Dictionary])

@export var game_controller: GameController
@export var bot_names: PackedStringArray = ["Alex", "Mira", "John"]
@export var bot_score_min: float = 0.2
@export var bot_score_max: float = 2.5
@export var bot_score_interval: float = 8.0

var standings: Array[Dictionary] = []
var rng := RandomNumberGenerator.new()
var bot_timer := Timer.new()


func _ready() -> void:
	rng.randomize()

	add_child(bot_timer)
	bot_timer.wait_time = bot_score_interval
	bot_timer.timeout.connect(_add_random_bot_score)
	_create_standings()

	if game_controller != null:
		game_controller.score_changed.connect(_on_player_score_changed)
		game_controller.match_finished.connect(_on_match_finished)

	bot_timer.start()
	_emit_sorted_standings()


func _create_standings() -> void:
	standings.clear()

	standings.append({
		"name": "Player",
		"score": 0.0,
		"is_player": true
	})

	for bot_name in bot_names:
		standings.append({
			"name": bot_name,
			"score": 0.0,
			"is_player": false
		})


func _on_player_score_changed(score: float) -> void:
	standings[0]["score"] = score
	_emit_sorted_standings()


func _emit_sorted_standings() -> void:
	standings_changed.emit(_get_sorted_standings())


func get_standings() -> Array[Dictionary]:
	return _get_sorted_standings()


func _get_sorted_standings() -> Array[Dictionary]:
	var sorted := standings.duplicate(true)
	sorted.sort_custom(func(a, b): return a["score"] > b["score"])
	return sorted


func _add_random_bot_score() -> void:
	if game_controller != null and not game_controller.is_match_running:
		return
	if standings.size() <= 1:
		return

	var bot_index := rng.randi_range(1, standings.size() - 1)
	var added_score := rng.randf_range(bot_score_min, bot_score_max)

	standings[bot_index]["score"] += added_score
	_emit_sorted_standings()


func _on_match_finished() -> void:
	bot_timer.stop()

	var sorted := _get_sorted_standings()
	final_standings_ready.emit(sorted)
