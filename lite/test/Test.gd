extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	var a: Vector2 = Vector2(5,5)
	var b: Vector2 = Vector2(60,1) #rightup
	var c: Vector2 = Vector2(60,60) #rightdown
	var d: Vector2 = Vector2(2,60) #leftdown
	var e: Vector2 = Vector2(1,2) #leftup
	
	print(a.direction_to(b))
	print(a.direction_to(c))
	print(a.direction_to(d))
	print(a.direction_to(e))
	
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
