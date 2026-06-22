class_name ScoreBoardRow
extends HBoxContainer

@onready var rank_label: Label = $RankLabel
@onready var name_label: Label = $NameLabel
@onready var score_label: Label = $ScoreLabel


func set_score_row(rank: int, competitor_name: String, score: float, is_player: bool) -> void:
	rank_label.text = "%d." % rank
	name_label.text = competitor_name
	score_label.text = "%.2f kg" % score

	if is_player:
		modulate = Color(1.0, 0.95, 0.65)
	else:
		modulate = Color.WHITE
