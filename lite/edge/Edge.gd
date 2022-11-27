extends Node2D


export var type: String = "PATH"
var from: Node2D
var to: Node2D
export var weight: int = 1
#draw var
#var font: Font

func _ready():
#	font = DynamicFont.new()
#	font.font_data = load("res://assets/seguihis.ttf")
#	font.size = 64
	pass

## initiate edge to connection vertex in one line
func init_object(_from: Node2D = null, _to: Node2D = null, _type: String = "PATH", direction: Vector2 = Vector2.ZERO):
	from = _from
	to = _to
	type = _type
	weight = randi() % 3 + 1
	var fromString = from.name if from != null else "null"
	var toString = to.name if to != null else "null"
	if direction != Vector2.ZERO:
		var mirror: Vector2 = direction
		mirror = Vector2(mirror.x * -1, mirror.y) if mirror.x != 0 else Vector2(mirror.x, mirror.y * -1)
		from.connections[direction] = to
		to.connections[mirror] = from
	name = str(fromString) + "to" + str(toString)

#disable for performance
#func _process(delta):
#	var fromPosition = from.position if from != null else to.position
#	var toPosition = to.position if to != null else from.position
#	$Line2D.points = [fromPosition, toPosition]
#	update()
#	pass

#func _draw():
#	var color: Color = Color.gray
#	var lineSize: float = 8
#	match type:
#		TYPE_EDGE.PATH: 
#			color = Color.gray
#			lineSize = 8
#		TYPE_EDGE.KEY_LOCK:
#			color = Color.green
#			lineSize = 4
#	var fromPosition = from.global_position if from != null else to.global_position
#	var toPosition = to.global_position if to != null else from.global_position
#	draw_line(fromPosition - Vector2(64,0).rotated(fromPosition.angle_to_point(toPosition)), toPosition - Vector2(64,0).rotated(toPosition.angle_to_point(fromPosition)), color, lineSize)
#	draw_string(font, (fromPosition + toPosition) / Vector2(2,2), str(weight), color)
#	draw_line(toPosition - Vector2(64,0).rotated(toPosition.angle_to_point(fromPosition)), toPosition - Vector2(128,0).rotated(toPosition.angle_to_point(fromPosition) + deg2rad(15)), color, lineSize)
#	draw_line(toPosition - Vector2(64,0).rotated(toPosition.angle_to_point(fromPosition)), toPosition - Vector2(128,0).rotated(toPosition.angle_to_point(fromPosition) + deg2rad(-15)), color, lineSize)

func _to_string() -> String:
	var fromString = from.name if from != null else "null"
	var toString = to.name if to != null else "null"
	return "{%s to %s : %s}" %[fromString, toString, type]
