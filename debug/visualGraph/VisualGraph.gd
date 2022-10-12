extends Node2D


const Vertex = preload("res://debug/visualNode/VisualNode.tscn")
const Edge = preload("res://debug/visualEdge/VisualEdge.tscn")

## objec function value
onready var variation: float = 0.0
onready var exploration: int = 0 #???
onready var shortesPathLength: int = 0
onready var standardShortPath: float = 0.0
onready var weightDuration: float = 0.0
onready var optionReplay: float = 0.0

## fitness function value
onready var fitness: float = 0.0

# (1) generic method for a graph ===============================================

## get all vertices in graph
func get_vertices() -> Array:
	return $Vertices.get_children()

## get all edges in graph
func get_edges() -> Array:
	return $Edges.get_children()

## add vertex to graph
func add_vertex(name: String = "", type: String = "") -> Node:
	var _name = "Node" + str($Vertices.get_child_count()) if name == "" else name
	var _type = TYPE_VERTEX.TASK if type == "" else type
	var vertex = Vertex.instance()
	vertex.init(_name, _type)
	$Vertices.add_child(vertex)
	return vertex

## connecting between two vertex in graph with an edge
func connect_vertex(from: Node, to: Node, type: String = ""):
	var edge = Edge.instance()
	var _type = type if type != "" else TYPE_EDGE.PATH
	edge.init(from.name, to.name, _type)
	$Edges.add_child(edge)
