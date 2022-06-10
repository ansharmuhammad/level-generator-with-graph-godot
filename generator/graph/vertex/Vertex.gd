extends Node

##
## Vertex Scene.
##
## @desc:
##     A scene object represent vertex(node).
##

export var type: String = "TASK"
export var position: Vector2

## var which contains info about which part of the node this node belongs to
var subOf: Node
export var subOfStr: String = ""

## initiate vertex with name and type
func init(_name: String = "", _type: String = "TASK"):
	name = _name
	type = _type

func _to_string() -> String:
	if subOfStr == "":
		return "{%s %s}" %[name, type]
	return "{%s %s ,%s}" %[name, type, subOf]
