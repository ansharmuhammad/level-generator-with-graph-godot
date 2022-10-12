extends Control

export onready var population: int = 3

const Graph = preload("res://generator/graph/Graph.tscn")

onready var placeGraph: Node = null
onready var result: Node = null

onready var Drawer = $Drawer
onready var Graphs = $Graphs
onready var Result = $Result
onready var TransformRule = $TransformRule
onready var Tester = $Tester
onready var Recipe = $Recipe
onready var Mapping = $Mapping
onready var faces

var countSplit: int = 0

func _ready():
	running()

func running():
	var graph: Node = _generate(population)
	var result = graph.duplicate()
	result.name = "GrapResult"
	Result.add_child(result)
	TransformRule.transform(result)
	Drawer.to_dot(result)
	_splitting_edges(result)
	
#	faces = _get_sorted_face(result)
	faces = Tester.GetFaces(result)
#	faces = _rearrange_faces(faces)
	for face in faces:
		printraw("face = [")
		for vertex in face:
			printraw(vertex + ", ")
		print("]")

func _generate(population: int) -> Node:
	for n in range(population):
		var graph = Graph.instance()
		Graphs.add_child(graph)
		graph.name = 'Graph' + str(n)
		graph.add_vertex('Node0', TYPE_VERTEX.INIT)
		graph.connect_vertex_by_name('Node0', "",TYPE_EDGE.PATH)
		
		for step in Recipe.get_children():
			step.execute(graph)
		
		graph.get_variation()
		graph.get_exploration()
		graph.get_shortest_path()
	#TODO: CHOOSE BEST GRAPH
	var bestGraph: Node = null
	var logidx = 0
	for graph in Graphs.get_children():
		#(logidx)
		logidx += 1
		graph.get_fitness()
		if bestGraph == null:
			bestGraph = graph
			#("best ", logidx)
		elif bestGraph.fitness < graph.fitness:
			bestGraph = graph
			#("best ", logidx)
	
	return bestGraph

func _splitting_edges(graph: Node):
	var search: bool = true
	while search:
		search = false
		for vertex in graph.get_vertices():
			if vertex.type == TYPE_VERTEX.TASK and graph.get_degree_of(vertex, TYPE_EDGE.PATH) > 4:
				countSplit += 1
				var newVertex = graph.add_vertex()
				newVertex.name = vertex.name + "," + str(countSplit)
				var edges = graph.get_edges_of(vertex)
				print("edges", edges)
				for i in range(edges.size()/2):
					if edges[i].from == vertex.name:
						edges[i].from = newVertex.name
					elif edges[i].to == vertex.name:
						edges[i].to = newVertex.name
				graph.connect_vertex(vertex, newVertex)
		for vertex in graph.get_vertices():
			if vertex.type == TYPE_VERTEX.TASK and graph.get_degree_of(vertex, TYPE_EDGE.PATH) > 4:
				search = true
				break
	Drawer.to_dot(graph, "splitting edges")

func _rearrange_faces(faces: Array) -> Array:
	#get the biggest face and remove from faces for a while
	var bigFace: Array = faces.pop_front()
	
	var copyFace: Array = faces.duplicate()
	
	#clean from deadend
	for face in copyFace:
		_remove_Deadend(face)
	print(copyFace)
	
	var weightList: Array = []
	for i in range(copyFace.size()):
		var intersect: int = 0
		for vertex in copyFace[i]:
			for j in range(copyFace.size()):
				if copyFace[j].has(vertex) and j != i :
					intersect += 1
					break
		var dict: Dictionary = {
			"idx": i,
			"size": copyFace[i].size(),
			"weight": copyFace[i].size() - intersect
		}
		weightList.append(dict)
	
	weightList.sort_custom(self, "_sort_weight_then_size")
	
	print("weightList:")
	print(weightList)
	
	var newFaces: Array = []
	
	for item in weightList:
		newFaces.append(faces[item["idx"]])
	newFaces.append(bigFace)
	
	return newFaces

func _remove_Deadend(face: Array) -> Array:
	for i in range(face.size()):
		var nexidx: int = i + 1 if (i + 1) < face.size() else 0
		if face[i-1] == face[nexidx]:
			var deadend = face[i]
			var connect = face[i-1]
			face.erase(deadend)
			face.erase(connect)
			return _remove_Deadend(face)
	return face

func _sort_weight_then_size(a,b):
	if a["weight"] < b["weight"]:
		return true
	elif a["weight"] == b["weight"] and a["size"] < b["size"]:
		return true
	return false
