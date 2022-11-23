extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	var grid: Vector2 = Vector2(100,100)
	var a: Vector2 = Vector2(0, 0)
	var b: Vector2 = Vector2(5, 5)
	var dir = (b - a).normalized()
	var angle = rad2deg(a.angle_to_point(b))
	var move = a.move_toward(b, 10000).snapped(grid)
	var betweenSnap = ((a + b)/2).snapped(grid)
	print(dir)
	print(dir.sign())
	print(angle)
	print(rad2deg(b.angle()))
	print(move)
	print(betweenSnap)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
