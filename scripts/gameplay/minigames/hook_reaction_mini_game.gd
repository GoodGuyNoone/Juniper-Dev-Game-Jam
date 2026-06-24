class_name HookReactionMiniGame
extends Control

signal completed(success: bool)

@export var duration: float = 2.0
@export var input_action: StringName = &"interact"
@export var key_text: String = "E"
@export var ring_radius: float = 46.0
@export var ring_width: float = 7.0
@export var track_color: Color = Color(0.1, 0.1, 0.1, 0.65)
@export var progress_color: Color = Color(0.95, 0.82, 0.2, 1.0)

var is_running := false
var time_left := 0.0
var progress := 1.0

@onready var key_label: Label = %KeyLabel
@onready var timer_label: Label = %TimerLabel


func _ready() -> void:
	hide()
	set_process(false)


func start() -> void:
	time_left = maxf(0.01, duration)
	progress = 1.0
	is_running = true
	key_label.text = key_text
	timer_label.text = "%.1f" % time_left
	show()
	set_process(true)
	queue_redraw()


func cancel() -> void:
	if not is_running:
		return

	_finish(false)


func _process(delta: float) -> void:
	if not is_running:
		return

	if Input.is_action_just_pressed(input_action):
		_finish(true)
		return

	time_left = maxf(0.0, time_left - delta)
	progress = time_left / maxf(0.01, duration)
	timer_label.text = "%.1f" % time_left
	queue_redraw()

	if time_left <= 0.0:
		_finish(false)


func _draw() -> void:
	var center := size * 0.5
	var start_angle := -PI * 0.5
	var end_angle := start_angle + TAU * progress

	draw_arc(center, ring_radius, 0.0, TAU, 96, track_color, ring_width, true)
	draw_arc(center, ring_radius, start_angle, end_angle, 96, progress_color, ring_width, true)


func _finish(success: bool) -> void:
	is_running = false
	hide()
	set_process(false)
	completed.emit(success)
