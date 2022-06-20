extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	var array = [1,2,3,4]
	print(array)
	pv(array)
	print(array)

func pv(array):
	for i in array:
		i + 2
	array.append(5)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
