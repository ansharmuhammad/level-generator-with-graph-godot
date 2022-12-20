extends Node2D


export var type: String = "TASK"

var subOf: Node2D
var subs: Array = []

#positioning
var connections: Dictionary = {
	Vector2.UP: null,
	Vector2.DOWN: null,
	Vector2.LEFT: null,
	Vector2.RIGHT: null
}

func _ready():
	pass

## initiate vertex with name and type
func init_object(_name: String = "", _type: String = "TASK"):
	name = _name
	type = _type

func is_element() -> bool:
	if type == TYPE_VERTEX.TASK or type == TYPE_VERTEX.ROOM or type == TYPE_VERTEX.CAVE or type == TYPE_VERTEX.CONNECTOR:
		return false
	return true

func connection_reset():
	connections = {
		Vector2.UP: null,
		Vector2.DOWN: null,
		Vector2.LEFT: null,
		Vector2.RIGHT: null
	}

func _to_string() -> String:
	if subOf == null :
		return "{%s %s}" %[name, type]
	return "{%s %s ,sub of %s}" %[name, type, subOf.name]
