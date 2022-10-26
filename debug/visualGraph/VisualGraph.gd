extends Node2D

onready var label = $Label
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

var index: int

func initObject(_name: String, _index: int):
	name = _name
	$Label.text = _name
	index = _index

# (1) generic method for a graph ===============================================

## get all vertices in graph
func get_vertices() -> Array:
	return $Vertices.get_children()

## get all edges in graph
func get_edges() -> Array:
	return $Edges.get_children()

## get list edges on a vertex
func get_edges_of(vertex: Node, type: String = "") -> Array:
	var listEdge: Array = []
	for edge in $Edges.get_children():
		if edge.from == vertex or edge.to == vertex:
			if type == "":
				listEdge.append(edge)
			elif edge.type == type:
				listEdge.append(edge)
	return listEdge

## add vertex to graph
func add_vertex(name: String = "", type: String = "") -> Node:
	var _name = "Node" + str($Vertices.get_child_count()) if name == "" else name
	var _type = TYPE_VERTEX.TASK if type == "" else type
	var vertex = Vertex.instance()
	vertex.initObject(_name, _type)
	$Vertices.add_child(vertex)
	return vertex

## connecting between two vertex in graph with an edge
func connect_vertex(from: Node, to: Node, type: String = ""):
	var edge = Edge.instance()
	var _type = type if type != "" else TYPE_EDGE.PATH
	edge.initObject(from, to, _type)
	$Edges.add_child(edge)

## get vertex object by its name
func get_vertex_by_name(vertexName: String) -> Node:
	return $Vertices.get_node(vertexName)

## get vertex object by its name
func get_vertex(vertex: Node2D) -> Node:
	return $Vertices.get_node(vertex.name)

func is_place(vertex: Node) -> bool:
	if vertex.type == TYPE_VERTEX.TASK or vertex.type == TYPE_VERTEX.SECRET:
		return true
	return false

func is_element(vertex: Node) -> bool:
	var element: Array = [
		TYPE_VERTEX.KEY,
		TYPE_VERTEX.LOCK,
		TYPE_VERTEX.OBSTACLE,
		TYPE_VERTEX.REWARD
	]
	return true if element.find(vertex.type) != -1 else false

## get list of outgoing edges on a vertex
func get_outgoing_edges(vertex: Node, type: String = "") -> Array:
	var listEdge: Array = []
	for edge in $Edges.get_children():
		if edge.from == vertex:
			if type == "":
				listEdge.append(edge)
			elif edge.type == type:
				listEdge.append(edge)
	return listEdge

## get list outgoing edges on a vertex
func get_outgoing_vertex(vertex: Node, typeEdge: String = "") -> Array:
	var listVertex: Array = []
	var edges: Array = get_outgoing_edges(vertex, typeEdge)
	for edge in edges:
		var toVertex: Node = get_vertex(edge.to)
		if listVertex.find(toVertex) == -1:
			listVertex.append(toVertex)
	return listVertex

## get sum of outgoing edges on a vertex
func get_outdegree(vertex: Node, typeEdge: String = "") -> int:
	return get_outgoing_edges(vertex, typeEdge).size()
# (1) end ======================================================================

# (2) function fitness =========================================================
func get_variation():
	var Ed: float = 0
	var edges: Array = []
	edges.append_array($Edges.get_children())
	for edge in edges:
		var from = get_vertex(edge.from)
		var to = get_vertex(edge.to)
		if (from.type != TYPE_VERTEX.START or from.type != TYPE_VERTEX.GOAL) and (to.type != TYPE_VERTEX.START or to.type != TYPE_VERTEX.GOAL) and (from.type != to.type):
			Ed += 1
	edges.pop_back()
	edges.pop_front()
	var E: float = edges.size()
	var fe: float = Ed/E
	variation = fe
	return variation

func get_exploration(): #???
	exploration = $Vertices.get_child_count()
	return exploration

func get_weight_duration() -> float:
	var preferred_value = 2
	var sumWeight = 0
	var edges: Array = get_edges()
	for edge in edges:
		sumWeight += edge.weight
	var result: float =  abs(sumWeight - (edges.size() * preferred_value)) / edges.size()
	weightDuration = 1 - result
	return weightDuration

func get_option_replay() -> float:
	var sum_branched_vertex: float = 0.0
	var vertices: Array = get_vertices()
	for vertex in vertices:
		if get_outdegree(vertex) > 1 :
			sum_branched_vertex += 1
	var result: float = sum_branched_vertex / vertices.size()
	optionReplay = result
	return optionReplay

func get_shortest_path() -> int:
	var start: Node = null
	var goal: Node = null
	for vertex in $Vertices.get_children():
		if start == null or goal == null:
			if vertex.type == TYPE_VERTEX.START:
				start = vertex
			if vertex.type == TYPE_VERTEX.GOAL:
				goal = vertex
		else:
			break
	
	var prev: Dictionary = _solve_path(start)
	
	var shortesPath = _reconstruc_path(start, goal, prev)
	shortesPathLength = shortesPath.size()
	return shortesPathLength

func _solve_path(startVertex: Node) -> Dictionary:
	var queue: Array = []
	queue.push_back(startVertex)
	var visitedDict: Dictionary = {}
	var prevDict: Dictionary = {}
	for vertex in $Vertices.get_children():
		visitedDict[vertex.name] = false if vertex.name != startVertex.name else true
		prevDict[vertex.name]= null
	while !queue.empty():
		var vertex = queue.front()
		queue.pop_front()
		var edges: Array = get_outgoing_edges(vertex)
		for edge in edges:
			if !visitedDict[edge.to.name] and edge.type == TYPE_EDGE.PATH:
				queue.push_back(get_vertex(edge.to))
				visitedDict[edge.to.name] = true
				prevDict[edge.to.name] = vertex.name
	return prevDict

func _reconstruc_path(startVertex: Node, goalVertex: Node, prevDict: Dictionary) -> Array:
	var path: Array = []
	var at = goalVertex.name
	while at != null:
		path.append(at)
		at = prevDict[at]
	
	path.invert()
	
	if path[0] == startVertex.name:
		return path
	return []

func get_standard_short_path() -> float:
	var preferred_value = 30
	var shortPathLength: float = get_shortest_path()
	var vertices = get_vertices()
	var shortPathPercentage: float = (shortPathLength / vertices.size()) * 100
	var result: float = 1 - (abs(preferred_value -shortPathPercentage)/preferred_value)
	standardShortPath = result
	return result

func get_fitness() -> float:
	var variation = get_variation()
	var exploration = get_exploration()
	var weighDuration = get_weight_duration()
	var optionReplay = get_option_replay()
	var standardShortPath = get_standard_short_path()
	
	var result: float = (variation + weighDuration + optionReplay + standardShortPath)/4
	
	fitness = result
	return fitness

# (2) end ======================================================================
