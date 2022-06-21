extends Node2D

var dfont
onready var tilemap = get_parent().get_node(".")

func _ready():
	dfont = DynamicFont.new()
	dfont.font_data = load("res://assets/seguihis.ttf")
	dfont.size = 12

func _draw():
	if tilemap.posCells.empty():
		return false
	for pos in tilemap.posCells.keys():
		var node: String = tilemap.posCells[pos]
		draw_string(dfont, tilemap.map_to_world(tilemap._str2vec(pos)) + Vector2(3,15), node.lstrip("Node"), Color.black)
#	draw_string(dfont, tilemap.map_to_world(Vector2(5,5)) + Vector2(3,15) ,"5,5", Color.black)
