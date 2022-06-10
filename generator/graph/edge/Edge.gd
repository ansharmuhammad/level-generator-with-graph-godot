extends Node

##
## Edge Scene.
##
## @desc:
##     A scene for connecting between 2 Vertex.
##

export var type: String = "PATH"
export var from: String
export var to: String
export var weight: int = 1

## initiate edge to connection vertex in one line
func init(_from: String = "", _to: String = "", _type: String = "PATH"):
	from = _from
	to = _to
	type = _type
	name = str(_from) + "to" + str(_to)
	randomize()
	weight = randi() % 3 + 1

func _to_string() -> String:
	return "{%s to %s : %s}" %[from, to, type]
