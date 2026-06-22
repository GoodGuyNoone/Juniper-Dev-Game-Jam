class_name TimingBarMiniGame
extends Control

signal completed(success: bool)

@export var duration: float = 4.0
@export var marker_speed: float = 260
@export var success_zone_height: float = 64.0

var is_running := false
var time_left := 0.0
var marker_direction = 1.0
var rng = RandomNumberGenerator.new()

@onready var bar: ColorRect = %Bar
@onready var success_zone: ColorRect = %SuccessZone
@onready var marker: ColorRect = %Marker
@onready var timer_label: Label = %TimerLabel

func _ready() -> void:
	rng.randomize()
	hide()


func start() -> void:
	show()
	is_running = true
	time_left = duration
	marker_direction = 1.0

	_randomize_success_zone()
	_reset_marker()


func stop() -> void:
	is_running = false
	hide()


func cancel() -> void:
	if not is_running:
		return

	_finish(false)


func _process(delta: float) -> void:
	if not is_running: 
		return

	time_left -= delta
	if time_left <= 0.0:
		_finish(false)
		return
	
	_move_marker(delta)
	timer_label.text = "%.1f" % time_left


func _input(event: InputEvent) -> void:
	if not is_running: 
		return

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			get_viewport().set_input_as_handled()
			_try_click()


func _randomize_success_zone() -> void:
	var zone_height: float = minf(success_zone_height, bar.size.y)
	var min_y: float = bar.position.y
	var max_y: float = bar.position.y + bar.size.y - zone_height

	success_zone.size.y = zone_height
	success_zone.position.y = rng.randf_range(min_y, max_y)

	success_zone.position.x = bar.position.x
	success_zone.size.x = bar.size.x


func _reset_marker() -> void:
	marker.position.x = bar.position.x
	marker.size.x = bar.size.x
	marker.position.y = bar.position.y


func _move_marker(delta: float) -> void:
	marker.position.y += marker_direction * marker_speed * delta

	var min_y: float = bar.position.y
	var max_y: float = bar.position.y + bar.size.y - marker.size.y

	if marker.position.y >= max_y:
			marker.position.y = max_y
			marker_direction = -1.0
	elif marker.position.y <= min_y:
			marker.position.y = min_y
			marker_direction = 1.0


func _try_click() -> void:
	print("clicked minigame")
	var marker_center_y := marker.position.y + marker.size.y * 0.5
	var zone_top := success_zone.position.y
	var zone_bottom := success_zone.position.y + success_zone.size.y

	var success := marker_center_y >= zone_top and marker_center_y <= zone_bottom
	_finish(success)


func _finish(success: bool) -> void:
	is_running = false
	hide()
	completed.emit(success)
