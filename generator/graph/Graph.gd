extends Node

const Vertex = preload("res://generator/graph/vertex/Vertex.tscn")
const Edge = preload("res://generator/graph/edge/Edge.tscn")

func add_vertex(name: String, type: String) -> void:
	var _name = "Node" + str($Vertices.get_child_count()) if name == "" else name
	var vertex = Vertex.instance()
	vertex.init(_name, type)
	$Vertices.add_child(vertex)

func connect_vertex(from: String, to: String, type: String) -> void:
	var edge = Edge.instance()
	edge.init(from, to, type)
	$Edges.add_child(edge)

func get_vertex_by_name(vertexName: String) -> Node:
	return $Vertices.get_node(vertexName)

func _ready():
	add_vertex("", TYPE_VERTEX.INIT)
	connect_vertex("Node0", "Node0", TYPE_EDGE.PATH)
	print($Vertices.get_children())
	print($Edges.get_children())
