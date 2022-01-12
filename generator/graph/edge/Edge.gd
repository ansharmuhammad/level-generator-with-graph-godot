extends Node

export var type: String = "PATH"
export var from: String
export var to: String

func init(_from: String = "", _to: String = "", _type: String = "PATH"):
	from = _from
	to = _to
	type = _type
	name = str(_from) + "to" + str(_to)

func _to_string() -> String:
	return "{%s to %s : %s}" %[from, to, type]
