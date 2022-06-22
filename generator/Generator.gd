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

func _ready():
	running()

func running():
	var graph: Node = _generate(population)
	var result = graph.duplicate()
	result.name = "GrapResult"
	Result.add_child(result)
	TransformRule.transform(result)
	Drawer.to_dot(result)
	faces = _get_sorted_face(result)
#	faces = Tester.GetFaces(graph)
#	faces.invert()
#	for face in faces:
#		printraw("face = [")
#		for vertex in face:
#			printraw(vertex + ", ")
#		print("]")

func _generate(_population: int) -> Node:
	for n in range(_population):
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

func _get_sorted_face(graph: Node):
	var faces = Tester.GetFaces(graph)
	var sortedFace: Array = []
	while !faces.empty():
		var shortestFace = 0
		for i in range(faces.size()):
			if faces[i].size() <= faces[shortestFace].size():
				shortestFace = i
		sortedFace.append(faces.pop_at(shortestFace))
	for face in sortedFace:
		printraw("face = [")
		for vertex in face:
			printraw(vertex + ", ")
		print("]")
	return sortedFace
