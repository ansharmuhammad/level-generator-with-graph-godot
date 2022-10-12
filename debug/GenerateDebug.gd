extends Node2D

onready var gui = $GUI
onready var popup = $GUI/WindowDialog


# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _input(event):
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == BUTTON_RIGHT:
		var mouse = get_viewport().get_mouse_position()
		popup.popup(Rect2(mouse.x, mouse.y, popup.rect_size.x, popup.rect_size.y))
