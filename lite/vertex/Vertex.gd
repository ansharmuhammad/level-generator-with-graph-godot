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

#draw var
#var gridSize: Vector2 = Vector2(300,300)
#var font: Font

func _ready():
#	font = DynamicFont.new()
#	font.font_data = load("res://assets/seguihis.ttf")
#	font.size = 32
	pass

## initiate vertex with name and type
func init_object(_name: String = "", _type: String = "TASK"):
	name = _name
	type = _type

func is_element() -> bool:
	if type == TYPE_VERTEX.TASK:
		return false
	return true

#disable for performance
#func _process(delta):
#	update()
#	pass

#func _draw():
#	var colorShape: Color = Color.white
#	var shapeRadius: float = 32
#	var textSymbol: String = "T"
#	var halfSymbolSize: Vector2 = font.get_string_size(textSymbol)
#	var halfNameSize: Vector2 = font.get_string_size(name)
#	#update type
#	match type:
#		TYPE_VERTEX.INIT:
#			colorShape = Color.white
#			textSymbol = "I"
#		TYPE_VERTEX.TASK:
#			colorShape = Color.white
#			textSymbol = "T"
#		TYPE_VERTEX.START:
#			colorShape = Color.maroon
#			textSymbol = "S"
#		TYPE_VERTEX.GOAL:
#			colorShape = Color.maroon
#			textSymbol = "G"
#		TYPE_VERTEX.SECRET:
#			colorShape = Color.aliceblue
#			textSymbol = "St"
#		TYPE_VERTEX.OBSTACLE:
#			colorShape = Color.red
#			textSymbol = "O"
#		TYPE_VERTEX.REWARD:
#			colorShape = Color.yellow
#			textSymbol = "R"
#		TYPE_VERTEX.KEY:
#			colorShape = Color.greenyellow
#			textSymbol = "K"
#		TYPE_VERTEX.LOCK:
#			colorShape = Color.aqua
#			textSymbol = "L"
#	draw_circle(Vector2.ZERO, shapeRadius, colorShape)
#	draw_arc(Vector2.ZERO, shapeRadius * 2, 0, PI*2, 50, colorShape, 4)
#	draw_string(font, Vector2.ZERO + Vector2(-halfSymbolSize.x/2, halfSymbolSize.x/2), textSymbol, Color.black)
#	draw_string(font, Vector2.ZERO + Vector2(-halfNameSize.x/2, 0) - Vector2(0,shapeRadius*2), name, Color.black)

#get all sub nodes (vertives)
func get_subs()-> Array:
	return $subs.get_children()

#add to sub node
func add_sub(vertex: Node2D):
	$subs.add_child(vertex)

func _to_string() -> String:
	if subOf == null :
		return "{%s %s}" %[name, type]
	return "{%s %s ,sub of %s}" %[name, type, subOf.name]
