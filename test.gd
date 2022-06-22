extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	var arrayin = [
		[1,2,3,1,5,6],
		[2,3]
		]
	print(arrayin)
	
	var arrayout = [2,3]
	arrayin.erase(arrayout)
	print(arrayin)
	

