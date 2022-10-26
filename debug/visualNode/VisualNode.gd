extends RigidBody2D

onready var colShape = $CollisionShape2D
onready var sprite = $Sprite
onready var labelType = $VisualNode/LabelType
onready var shapeNormal = CircleShape2D.new()
onready var shapeSmall = CircleShape2D.new()

export var type: String = "TASK"

## var which contains info about which part of the node this node belongs to
var subOf: Node
export var subOfStr: String = ""

var is_held = false

func _ready():
	changeType(type)
	var shape = colShape.get_shape()
	set_process_input(true)
	shapeNormal.radius = 150
	shapeSmall.radius = 70

## initiate vertex with name and type
func initObject(_name: String = "", _type: String = "TASK"):
	name = _name
	$Sprite/Label.text = _name
	type = _type
"resource_name"
func changeLayer(layer: int):
	if layer == 0:
		set_collision_layer_bit(0, true)
		set_collision_mask_bit(0, true)
		set_collision_layer_bit(1, false)
		set_collision_mask_bit(1, false)
		$CollisionShape2D.modulate = Color.white
	else:
		set_collision_layer_bit(0, false)
		set_collision_mask_bit(0, false)
		set_collision_layer_bit(1, true)
		set_collision_mask_bit(1, true)
		$CollisionShape2D.modulate = Color.green

func changeType(_type: String):
	match _type:
		TYPE_VERTEX.INIT:
			$Sprite.modulate = Color.white
			$VisualNode/LabelType.text = "I"
			$CollisionShape2D.set_shape(shapeNormal)
		TYPE_VERTEX.TASK:
			$Sprite.modulate = Color.white
			$VisualNode/LabelType.text = "T"
			$CollisionShape2D.set_shape(shapeNormal)
		TYPE_VERTEX.START:
			$Sprite.modulate = Color.white
			$VisualNode/LabelType.text = "S"
			$CollisionShape2D.set_shape(shapeNormal)
		TYPE_VERTEX.GOAL:
			$Sprite.modulate = Color.white
			$VisualNode/LabelType.text = "G"
			$CollisionShape2D.set_shape(shapeNormal)
		TYPE_VERTEX.SECRET:
			$Sprite.modulate = Color.white
			$VisualNode/LabelType.text = "St"
			$CollisionShape2D.set_shape(shapeNormal)
		TYPE_VERTEX.OBSTACLE:
			$Sprite.modulate = Color.red
			$VisualNode/LabelType.text = "O"
			$CollisionShape2D.set_shape(shapeSmall)
		TYPE_VERTEX.REWARD:
			$Sprite.modulate = Color.yellow
			$VisualNode/LabelType.text = "R"
			$CollisionShape2D.set_shape(shapeSmall)
		TYPE_VERTEX.KEY:
			$Sprite.modulate = Color.greenyellow
			$VisualNode/LabelType.text = "K"
			$CollisionShape2D.set_shape(shapeSmall)
		TYPE_VERTEX.LOCK:
			$Sprite.modulate = Color.aqua
			$VisualNode/LabelType.text = "L"
			$CollisionShape2D.set_shape(shapeSmall)

func setColor(color: Color):
	sprite.modulate = color

func setScale(_scale: float):
	$Sprite.scale = Vector2(_scale, _scale)
	$CollisionShape2D.shape.radius = 150 * _scale

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
