extends Node

export var type: String = "TASK"
export var position: Vector2

func init(_name: String = "", _type: String = "TASK"):
	name = _name
	type = _type

func _to_string() -> String:
	return "{%s %s}" %[name, type]
