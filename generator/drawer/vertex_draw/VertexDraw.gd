extends RigidBody2D

func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func _draw():
	draw_circle(self.position, 10, Color.white)
	var label = Label.new()
	var font = label.get_font("")
	draw_string(font, self.position, self.name, Color.black)
	label.free()
