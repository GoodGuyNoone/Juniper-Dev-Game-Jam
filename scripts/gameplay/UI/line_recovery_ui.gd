class_name LineRecoveryUI
extends Control

@export var game_controller: GameController
@export var input_action: StringName = &"interact"
@export var key_text: String = "E"
@export var reset_duration: float = 1
@export var ring_radius: float = 46.0
@export var ring_width: float = 7.0
@export var track_color: Color = Color(0.1, 0.1, 0.1, 0.65)
@export var progress_color: Color = Color(0.95, 0.82, 0.2, 1.0)

var is_running := false
var duration := 1.0
var progress := 0.0

@onready var key_label: Label = %KeyLabel


func _ready() -> void:
	hide()
	set_process(false)

	if game_controller == null:
		push_warning("LineRecoveryUI has no GameController assigned.")
		return

	game_controller.line_recovery_started.connect(_on_line_recovery_started)
	game_controller.line_recovery_finished.connect(_on_line_recovery_finished)


func _process(delta: float) -> void:
	if not is_running:
		return

	if Input.is_action_pressed(input_action):
		progress = minf(1.0, progress + delta / duration)
		queue_redraw()
	elif progress > 0.0:
		progress = maxf(0.0, progress - delta / maxf(0.01, reset_duration))
		queue_redraw()

	if progress >= 1.0:
		game_controller.complete_line_recovery()


func _draw() -> void:
	var center := size * 0.5
	var start_angle := -PI * 0.5
	var end_angle := start_angle + TAU * progress

	draw_arc(center, ring_radius, 0.0, TAU, 96, track_color, ring_width, true)
	draw_arc(center, ring_radius, start_angle, end_angle, 96, progress_color, ring_width, true)


func _on_line_recovery_started(recovery_duration: float) -> void:
	duration = maxf(0.01, recovery_duration)
	progress = 0.0
	is_running = true
	key_label.text = key_text
	show()
	set_process(true)
	queue_redraw()


func _on_line_recovery_finished() -> void:
	is_running = false
	progress = 0.0
	hide()
	set_process(false)
	queue_redraw()
