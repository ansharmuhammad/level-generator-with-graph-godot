extends Node

##
## Graph Scene.
##
## @desc:
##     Scene object consisting of vertices and edges
##

const Vertex = preload("res://generator/graph/vertex/Vertex.tscn")
const Edge = preload("res://generator/graph/edge/Edge.tscn")

## objec function value
onready var variation: float = 0.0
onready var exploration: int = 0 #???
onready var shortesPathLength: int = 0
onready var standardShortPath: float = 0.0
onready var weightDuration: float = 0.0
onready var optionReplay: float = 0.0

# (1) generic method for a graph ===============================================

## fitness function value
onready var fitness: float = 0.0

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

## connecting between two vertex in graph with an edge with parameter name of those vertex
func connect_vertex_by_name(from: String, to: String, type: String) -> void:
	var edge = Edge.instance()
	var _type = type if type != "" else TYPE_EDGE.PATH
	edge.init(from, to, _type)
	$Edges.add_child(edge)

## get vertex object by its name
func get_vertex_by_name(vertexName: String) -> Node:
	return $Vertices.get_node(vertexName)

## get list of incoming edges on a vertex
func get_incoming_edges(vertex: Node, type: String = "") -> Array:
	var listEdge: Array = []
	for edge in $Edges.get_children():
		if edge.to == vertex.name:
			if type == "":
				listEdge.append(edge)
			elif edge.type == type:
				listEdge.append(edge)
	return listEdge

## get list of outgoing edges on a vertex
func get_outgoing_edges(vertex: Node, type: String = "") -> Array:
	var listEdge: Array = []
	for edge in $Edges.get_children():
		if edge.from == vertex.name:
			if type == "":
				listEdge.append(edge)
			elif edge.type == type:
				listEdge.append(edge)
	return listEdge

## get list edges on a vertex
func get_edges_of(vertex: Node, type: String = "") -> Array:
	var listEdge: Array = []
	for edge in $Edges.get_children():
		if edge.from == vertex.name or edge.to == vertex.name:
			if type == "":
				listEdge.append(edge)
			elif edge.type == type:
				listEdge.append(edge)
	return listEdge

## get sum of incoming edges on a vertex
func get_indegree(vertex: Node, typeEdge: String = "") -> int:
	return get_incoming_edges(vertex, typeEdge).size()

## get sum of outgoing edges on a vertex
func get_outdegree(vertex: Node, typeEdge: String = "") -> int:
	return get_outgoing_edges(vertex, typeEdge).size()

## get sum of edges on a vertex
func get_degree_of(vertex: Node, typeEdge: String = "") -> int:
	return get_edges_of(vertex, typeEdge).size()

## get list incoming edges on a vertex
func get_incoming_vertex(vertex: Node, typeEdge: String = "") -> Array:
	var listVertex: Array = []
	var edges: Array = get_incoming_edges(vertex, typeEdge)
	for edge in edges:
		var fromVertex: Node = get_vertex_by_name(edge.from)
		if listVertex.find(fromVertex) == -1:
			listVertex.append(fromVertex)
	return listVertex

## get list outgoing edges on a vertex
func get_outgoing_vertex(vertex: Node, typeEdge: String = "") -> Array:
	var listVertex: Array = []
	var edges: Array = get_outgoing_edges(vertex, typeEdge)
	for edge in edges:
		var toVertex: Node = get_vertex_by_name(edge.to)
		if listVertex.find(toVertex) == -1:
			listVertex.append(toVertex)
	return listVertex

## get list another vertex which connected on a vertex
func get_neighbors(vertex: Node, typeEdge: String = "") -> Array:
	var listVertex: Array = []
	var edges: Array
	
	edges = get_incoming_edges(vertex, typeEdge)
	for edge in edges:
		var fromVertex: Node = get_vertex_by_name(edge.from)
		if listVertex.find(fromVertex) == -1:
			listVertex.append(fromVertex)
	
	edges = get_outgoing_edges(vertex, typeEdge)
	for edge in edges:
		var toVertex: Node = get_vertex_by_name(edge.to)
		if listVertex.find(toVertex) == -1:
			listVertex.append(toVertex)
	return listVertex

func get_neighbors_name_by_name(vertexName: String, typeEdge: String = "") -> Array:
	var listVertex: Array = []
	var edges: Array
	
	edges = get_incoming_edges(get_vertex_by_name(vertexName), typeEdge)
	for edge in edges:
		var fromVertex: Node = get_vertex_by_name(edge.from)
		if listVertex.find(fromVertex) == -1:
			listVertex.append(fromVertex.name)
	
	edges = get_outgoing_edges(get_vertex_by_name(vertexName), typeEdge)
	for edge in edges:
		var toVertex: Node = get_vertex_by_name(edge.to)
		if listVertex.find(toVertex) == -1:
			listVertex.append(toVertex.name)
	return listVertex

## get list of vertex which didn't connected with any other vertex
func get_isolated(typeEdge: String = "") -> Array:
	var listVertex: Array = []
	for vertex in $Vertices.get_children():
		if get_degree_of(vertex, typeEdge) == 0:
			 listVertex.append(vertex)
	return listVertex

## get list of vertex which only have incoming edges
func get_sinks(typeEdge: String = "") -> Array:
	var listVertex: Array = []
	for vertex in $Vertices.get_children():
		if get_outdegree(vertex, typeEdge) == 0 and get_indegree(vertex, typeEdge) != 0:
			 listVertex.append(vertex)
	return listVertex

## get list of vertex which only have outgoing edges
func get_sources(typeEdge: String = "") -> Array:
	var listVertex: Array = []
	for vertex in $Vertices.get_children():
		if get_indegree(vertex, typeEdge) == 0 and get_outdegree(vertex, typeEdge) != 0:
			 listVertex.append(vertex)
	return listVertex

## invert value of "from" and "to" on a edge
func invert_edge(edge: Node):
	var tempFrom: String = edge.from
	var tempTo: String = edge.to
	edge.from = tempTo
	edge.to = tempFrom

# (1) end ======================================================================

# (2) methode for calculate fittness function ==================================

func get_variation():
	var Ed: float = 0
	var edges: Array = []
	edges.append_array($Edges.get_children())
	for edge in edges:
		var from = get_vertex_by_name(edge.from)
		var to = get_vertex_by_name(edge.to)
		if (from.type != TYPE_VERTEX.START or from.type != TYPE_VERTEX.GOAL) and (to.type != TYPE_VERTEX.START or to.type != TYPE_VERTEX.GOAL) and (from.type != to.type):
			Ed += 1
	edges.pop_back()
	edges.pop_front()
	var E: float = edges.size()
	var fe = Ed/E
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
	var result =  abs(sumWeight - (edges.size() * preferred_value)) / edges.size()
	weightDuration = 1 - result
	return weightDuration

func get_option_replay() -> float:
	var sum_branched_vertex = 0
	var vertices: Array = get_vertices()
	for vertex in vertices:
		if get_outdegree(vertex) > 1 : sum_branched_vertex += 1
	var result = 1 -  (sum_branched_vertex / vertices.size())
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

func get_standard_short_path() -> float:
	var preferred_value = 30
	var shortPathLength = get_shortest_path()
	var vertices = get_vertices()
	var shortPathPercentage = (shortPathLength / vertices.size()) * 100
	var result = 1 - (abs(preferred_value -shortPathPercentage)/preferred_value)
	standardShortPath = result
	return result

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
			if !visitedDict[edge.to] and edge.type == TYPE_EDGE.PATH:
				queue.push_back(get_vertex_by_name(edge.to))
				visitedDict[edge.to] = true
				prevDict[edge.to] = vertex.name
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

func get_fitness() -> float:
	var variation = get_variation()
	var weighDuration = get_weight_duration()
	var optionReplay = get_option_replay()
	var standardShortPath = get_standard_short_path()
	
	var result = (variation + weighDuration + optionReplay + standardShortPath)/4
	
	fitness = result
	return fitness

# (2) end ======================================================================

func is_element(vertex: Node) -> bool:
	var element: Array = [
		TYPE_VERTEX.KEY,
		TYPE_VERTEX.LOCK,
		TYPE_VERTEX.OBSTACLE,
		TYPE_VERTEX.REWARD
	]
	return true if element.find(vertex.type) != -1 else false

func is_place(vertex: Node) -> bool:
	if vertex.type == TYPE_VERTEX.TASK or vertex.type == TYPE_VERTEX.SECRET:
		return true
	return false

func _to_string() -> String:
	var output: String = ""
	output += "vertices:\n"
	for vertex in $Vertices.get_children():
		output += " " + str(vertex) + "\n"
	output += "edges:\n"
	for edge in $Edges.get_children():
		output += " " + str(edge) + "\n"
	return output

func get_adjacent_list(onlyPath: bool = true, typeEdge: String = "") -> Dictionary:
	var adjacentList: Dictionary = {}
	for vertex in get_vertices():
		var listNeihgbor: Array = []
		for neighbor in get_neighbors(vertex, typeEdge):
			listNeihgbor.append(neighbor.name)
		adjacentList[vertex.name] = listNeihgbor
	
	for key in adjacentList.keys():
		if adjacentList[key] == null:
			adjacentList.erase(key)
	return adjacentList
