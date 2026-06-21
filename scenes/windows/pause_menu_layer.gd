extends CanvasLayer

@onready var pause_menu = %PauseMenu

func _open_pause_menu():
	if pause_menu.has_method("open"):
		pause_menu.call("open")
	else:
		pause_menu.show()

func _on_pause_menu_hidden():
	hide()

func _on_visibility_changed():
	if visible:
		_open_pause_menu()

func _ready():
	visibility_changed.connect(_on_visibility_changed)
