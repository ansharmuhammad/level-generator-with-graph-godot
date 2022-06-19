extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	var a = Vector2(0,1)
	print("as vector = ",a)
	var b = "(" + str(a.x) + ", " + str(a.y) + ")"
	print("as string = "+b)
	var c = str2var("Vector2" + b)
	print("as str2var = ", c)
	
	var v = Vector2(0,9)
	print(v)
	pv(v)
	print(v)

func pv(v):
	v -= Vector2.UP
	print(v)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
