extends Line2D


export var type: String = "PATH"
var from: Node2D
var to: Node2D
export var weight: int = 1
export var color: Color = Color.black
export var lineSize: float = 5.0

var font: Font
var showLine: bool = true

func _ready():
	font = DynamicFont.new()
	font.font_data = load("res://assets/seguihis.ttf")
	font.size = 70

#disable for performance
func _physics_process(delta):
	update()

## initiate edge to connection vertex in one line
func init_object(_from: Node2D = null, _to: Node2D = null, _type: String = "PATH"):
	from = _from
	to = _to
	type = _type
	lineSize = 10.0 if type == TYPE_EDGE.PATH else 5.0
	weight = randi() % 3 + 1
	var fromString = from.name if from != null else "null"
	var toString = to.name if to != null else "null"
	name = str(fromString) + "to" + str(toString)

func _to_string() -> String:
	var fromString = from.name if from != null else "null"
	var toString = to.name if to != null else "null"
	return "{%s to %s : %s}" %[fromString, toString, type]

func _draw():
	if showLine:
		match type:
			TYPE_EDGE.PATH: 
				color = Color.black
				lineSize = 0.7
			TYPE_EDGE.KEY_LOCK:
				color = Color.green
				lineSize = 0.3
			_:
				color = Color.yellow
				lineSize = 0.3
		var fromPosition = from.position if from != null else to.position
		var toPosition = to.position if to != null else from.position
		draw_line(fromPosition - Vector2(50,0).rotated(fromPosition.angle_to_point(toPosition)), toPosition - Vector2(50,0).rotated(toPosition.angle_to_point(fromPosition)), color, lineSize)
		draw_string(font, (fromPosition + toPosition) / Vector2(2,2), str(weight), color)
		draw_line(toPosition - Vector2(50,0).rotated(toPosition.angle_to_point(fromPosition)), toPosition - Vector2(100,0).rotated(toPosition.angle_to_point(fromPosition) + deg2rad(15)), color, lineSize)
		draw_line(toPosition - Vector2(50,0).rotated(toPosition.angle_to_point(fromPosition)), toPosition - Vector2(100,0).rotated(toPosition.angle_to_point(fromPosition) + deg2rad(-15)), color, lineSize)

func _input(event):
	if event is InputEventMouseButton:
		if not event.pressed and event.button_index == BUTTON_LEFT:
			update()
