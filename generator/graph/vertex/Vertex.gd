extends Node

export var type: String = "TASK"
export var position: Vector2
export var subOfStr: String = ""
var subOf: Node

func init(_name: String = "", _type: String = "TASK"):
	name = _name
	type = _type

func _to_string() -> String:
	if subOfStr == "":
		return "{%s %s}" %[name, type]
	return "{%s %s ,%s}" %[name, type, subOf]
