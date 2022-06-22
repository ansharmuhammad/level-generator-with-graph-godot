extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	var arrayin = [1,2,3,1,5,6]
	arrayin.erase(1)
	print(arrayin)
	
	var pa = Vector2(2, 10)
	print(pa)
	var pb = Vector2(10, 4)
	print(pb)
	print(pa.direction_to(pb))

