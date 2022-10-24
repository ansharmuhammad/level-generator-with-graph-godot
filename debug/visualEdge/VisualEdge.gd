extends Line2D


export var type: String = "PATH"
var from: Node2D
var to: Node2D
export var weight: int = 1
export var color: Color = Color.black

func _ready():
	pass

## initiate edge to connection vertex in one line
func init(_from: Node2D = null, _to: Node2D = null, _type: String = "PATH"):
	from = _from
	to = _to
	type = _type
	color = Color.black if type == TYPE_EDGE.PATH else Color.yellow
	weight = randi() % 3 + 1
	var fromString = from.name if from != null else "null"
	var toString = to.name if to != null else "null"
	name = str(fromString) + "to" + str(toString)

func _to_string() -> String:
	var fromString = from.name if from != null else "null"
	var toString = to.name if to != null else "null"
	return "{%s to %s : %s}" %[fromString, toString, type]

func _draw():
	var fromPosition = from.position if from != null else to.position
	var toPosition = to.position if to != null else from.position
	draw_line(fromPosition, toPosition, color, 10)
	draw_line(toPosition, toPosition - Vector2(50,0).rotated(toPosition.angle_to_point(fromPosition) + deg2rad(30)), color, 10)
	draw_line(toPosition, toPosition - Vector2(50,0).rotated(toPosition.angle_to_point(fromPosition) + deg2rad(-30)), color, 10)

func _input(event):
	if event is InputEventMouseButton:
		if not event.pressed and event.button_index == BUTTON_LEFT:
			update()
