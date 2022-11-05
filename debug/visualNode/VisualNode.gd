extends RigidBody2D

onready var colShape = $CollisionShape2D
onready var sprite = $Sprite
onready var labelType = $VisualNode/LabelType
onready var shapeNormal = CircleShape2D.new()
onready var shapeSmall = CircleShape2D.new()

export var type: String = "TASK"
export var alwaysStatic: bool = false
export var move: bool = false
export var sub: Array = []

var newPos: Vector2

## var which contains info about which part of the node this node belongs to
var subOf: Node
export var subOfStr: String = ""

var is_held = false
var color = Color.black

func _ready():
	changeType(type)
	var shape = colShape.get_shape()
	set_process_input(true)
	shapeNormal.radius = 150
	shapeSmall.radius = 50

## initiate vertex with name and type
func initObject(_name: String = "", _type: String = "TASK"):
	name = _name
	$Sprite/Label.text = _name
	type = _type
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
			color = Color.white
		TYPE_VERTEX.TASK:
			$Sprite.modulate = Color.white
			$VisualNode/LabelType.text = "T"
			$CollisionShape2D.set_shape(shapeNormal)
			color = Color.white
		TYPE_VERTEX.START:
			$Sprite.modulate = Color.white
			$VisualNode/LabelType.text = "S"
			$CollisionShape2D.set_shape(shapeNormal)
			color = Color.green
		TYPE_VERTEX.GOAL:
			$Sprite.modulate = Color.white
			$VisualNode/LabelType.text = "G"
			$CollisionShape2D.set_shape(shapeNormal)
			color = Color.green
		TYPE_VERTEX.SECRET:
			$Sprite.modulate = Color.white
			$VisualNode/LabelType.text = "St"
			$CollisionShape2D.set_shape(shapeNormal)
			color = Color.green
		TYPE_VERTEX.OBSTACLE:
			$Sprite.modulate = Color.red
			$VisualNode/LabelType.text = "O"
			color = Color.green
#			$CollisionShape2D.set_shape(shapeSmall)
		TYPE_VERTEX.REWARD:
			$Sprite.modulate = Color.yellow
			$VisualNode/LabelType.text = "R"
			color = Color.green
#			$CollisionShape2D.set_shape(shapeSmall)
		TYPE_VERTEX.KEY:
			$Sprite.modulate = Color.greenyellow
			$VisualNode/LabelType.text = "K"
			color = Color.green
#			$CollisionShape2D.set_shape(shapeSmall)
		TYPE_VERTEX.LOCK:
			$Sprite.modulate = Color.aqua
			$VisualNode/LabelType.text = "L"
			color = Color.green
#			$CollisionShape2D.set_shape(shapeSmall)

func setColor(color: Color):
	sprite.modulate = color

func setScale(_scale: float):
	$Sprite.scale = Vector2(_scale, _scale)
#	$CollisionShape2D.shape.radius = 150 * _scale
	$CollisionShape2D.set_shape(shapeSmall)

func _to_string() -> String:
	if subOfStr == "":
		return "{%s %s}" %[name, type]
	return "{%s %s ,%s}" %[name, type, subOf]

func _draw():
#	draw_circle(position, colShape.shape.radius, color)
	draw_arc($Sprite.position, colShape.shape.radius + 50, 0, PI*2, 100, color, 5)

func _physics_process(delta):
	update()
	if is_held:
		global_position = lerp(global_position, get_global_mouse_position(), 25 * delta)

func _integrate_forces(state):
	if move:
		state.transform.origin = newPos
		move = false

# drag n drop function
func _input(event):
	if event is InputEventMouseButton:
		if not event.pressed and event.button_index == BUTTON_LEFT:
			is_held = false
			if !alwaysStatic:
				mode = RigidBody2D.MODE_CHARACTER

func _on_VisualNode_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == BUTTON_LEFT:
			is_held = true
			mode = RigidBody2D.MODE_STATIC
# end of drag n drop function
