extends Node2D

var dfont
onready var tilemap = get_parent().get_node(".")

func _ready():
	dfont = DynamicFont.new()
	dfont.font_data = load("res://assets/seguihis.ttf")
	dfont.size = 12

func _draw():
	draw_string(dfont, tilemap.map_to_world(Vector2(5,5)) + Vector2(3,15) ,"5,5", Color.black)
