class_name ReelSpinMiniGame
extends Control

signal completed(success: bool)

@export var duration: float = 10.0
@export var required_rotations: float = 4.0
@export var spin_direction: float = 1.0
@export var dead_zone_radius: float = 24.0
@export var handle_grab_radius: float = 24.0

var is_running := false
var is_dragging_handle := false
var time_left := 0.0
var progress := 0.0
var previous_angle := 0.0
var has_previous_angle := false

@onready var reel_root: Control = %ReelRoot
@onready var reel_face: Control = %ReelFace
@onready var handle_pivot: Control = %HandlePivot
@onready var reel_handle: Control = %ReelHandle
@onready var progress_bar: ProgressBar = %ProgressBar
@onready var timer_label: Label = %TimerLabel


func _ready() -> void:
	hide()


func start() -> void:
	show()
	is_running = true
	is_dragging_handle = false
	time_left = duration
	progress = 0.0
	has_previous_angle = false
	_set_reel_angle(0.0)
	progress_bar.value = 0.0


func _process(delta: float) -> void:
	if not is_running:
		return

	time_left -= delta
	timer_label.text = "%.1f" % time_left

	if time_left <= 0.0:
		_finish(false)


func _input(event: InputEvent) -> void:
	if not is_running:
		return

	if event is InputEventMouseButton:
		if event.button_index != MOUSE_BUTTON_LEFT:
			return

		if event.pressed and _is_mouse_on_handle():
			is_dragging_handle = true
			has_previous_angle = false
			handle_mouse_spin()
			get_viewport().set_input_as_handled()
		elif not event.pressed and is_dragging_handle:
			is_dragging_handle = false
			has_previous_angle = false
			get_viewport().set_input_as_handled()

	if event is InputEventMouseMotion and is_dragging_handle:
		handle_mouse_spin()
		get_viewport().set_input_as_handled()


func handle_mouse_spin() -> void:
	var center := reel_root.get_global_rect().get_center()
	var to_mouse := get_global_mouse_position() - center

	if to_mouse.length() < dead_zone_radius:
		return
	
	var current_angle := to_mouse.angle()
	_set_reel_angle(current_angle)

	if not has_previous_angle:
		previous_angle = current_angle
		has_previous_angle = true
		return

	var angle_delta := wrapf(current_angle - previous_angle, -PI, PI)
	previous_angle = current_angle

	var useful_delta := maxf(0.0, angle_delta * spin_direction)
	progress += useful_delta / TAU
	progress_bar.value = minf(progress / required_rotations * 100.0, 100.0)

	if progress >= required_rotations:
		_finish(true)


func _is_mouse_on_handle() -> bool:
	var handle_center := reel_handle.get_global_rect().get_center()
	return get_global_mouse_position().distance_to(handle_center) <= handle_grab_radius


func _set_reel_angle(angle: float) -> void:
	handle_pivot.rotation = angle
	reel_face.rotation = angle


func _finish(success: bool) -> void:
	is_running = false
	is_dragging_handle = false
	has_previous_angle = false
	hide()
	completed.emit(success)
