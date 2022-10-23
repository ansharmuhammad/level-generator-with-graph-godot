extends RigidBody2D

onready var colShape = $CollisionShape2D
onready var sprite = $Sprite
onready var labelType = $VisualNode/LabelType

export var type: String = "TASK"

## var which contains info about which part of the node this node belongs to
var subOf: Node
export var subOfStr: String = ""

var is_held = false

func _ready():
	scale = Vector2(0.5, 0.5)
	var shape = colShape.get_shape()
	shape.radius = 300 * scale.x
	sprite.modulate = Color.white
	set_process_input(true)

## initiate vertex with name and type
func init(_name: String = "", _type: String = "TASK"):
	name = _name
	type = _type
	$Sprite/Label.text = _name
	match _type:
		TYPE_VERTEX.TASK:
			$Sprite.modulate = Color.white
			$VisualNode/LabelType.text = "T"
		TYPE_VERTEX.START:
			$Sprite.modulate = Color.white
			$VisualNode/LabelType.text = "S"
		TYPE_VERTEX.GOAL:
			$Sprite.modulate = Color.white
			$VisualNode/LabelType.text = "G"
		TYPE_VERTEX.SECRET:
			$Sprite.modulate = Color.white
			$VisualNode/LabelType.text = "St"
		TYPE_VERTEX.OBSTACLE:
			$Sprite.modulate = Color.red
			$VisualNode/LabelType.text = "O"
		TYPE_VERTEX.REWARD:
			$Sprite.modulate = Color.yellow
			$VisualNode/LabelType.text = "R"
		TYPE_VERTEX.KEY:
			$Sprite.modulate = Color.greenyellow
			$VisualNode/LabelType.text = "K"
		TYPE_VERTEX.LOCK:
			$Sprite.modulate = Color.blue
			$VisualNode/LabelType.text = "L"

func setColor(color: Color):
	sprite.modulate = color

func setScale(_scale: float):
	scale = Vector2(_scale, _scale)

func _to_string() -> String:
	if subOfStr == "":
		return "{%s %s}" %[name, type]
	return "{%s %s ,%s}" %[name, type, subOf]

# drag n drop function
func _physics_process(delta):
	if is_held:
		global_position = lerp(global_position, get_global_mouse_position(), 25 * delta)

func _input(event):
	if event is InputEventMouseButton:
		if not event.pressed and event.button_index == BUTTON_LEFT:
			is_held = false
			mode = RigidBody2D.MODE_CHARACTER

func _on_VisualNode_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == BUTTON_LEFT:
			is_held = true
			mode = RigidBody2D.MODE_STATIC
# end of drag n drop function
