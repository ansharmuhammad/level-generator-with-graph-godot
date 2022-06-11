extends Control

export onready var population: int = 3

const Graph = preload("res://generator/graph/Graph.tscn")
const Tester = preload("res://generator/tester/Tester.cs")

onready var placeGraph: Node = null

onready var result: Node = null

func _ready():
	running()

func running():
	var graph: Node = _generate(population)
	var result = graph.duplicate()
	result.name = "GrapResult"
	$Result.add_child(result)
	_transform(result)
	$Drawer.to_dot(result)
	var faces = $Tester.GetFaces(result)
	print(faces)

func _generate(_population: int) -> Node:
	for n in range(_population):
		var graph = Graph.instance()
		$Graphs.add_child(graph)
		graph.name = 'Graph' + str(n)
		graph.add_vertex('Node0', TYPE_VERTEX.INIT)
		graph.connect_vertex_by_name('Node0', "",TYPE_EDGE.PATH)
		
		for step in $Recipe.get_children():
			step.execute(graph)
		
		graph.get_variation()
		graph.get_exploration()
		graph.get_shortest_path()
	#TODO: CHOOSE BEST GRAPH
	var bestGraph: Node = null
	for graph in $Graphs.get_children():
		graph.get_fitness()
		if bestGraph == null:
			bestGraph = graph
		elif bestGraph.fitness < graph.fitness:
			bestGraph = graph
	
	return bestGraph

func _transform(graph: Node):
	$Drawer.to_dot(graph)
	#create place rule
	for vertex in graph.get_vertices():
		_create_entrance(graph, vertex)
		_create_goal(graph, vertex)
		_create_secret(graph, vertex)
	
#	#clean outside element rule
	while _outside_element_exist(graph):
		var execute: int = randi() % 4
		match execute:
			0: _add_element_before_place(graph)
			1: _add_lock_after_place(graph)
			2: _place_key_element(graph)
			3: _add_lock_after_place(graph)
	
	#transformative rule

func _create_entrance(graph: Node, vertex: Node):
	#create entrance
	if vertex.type == TYPE_VERTEX.START:
		var newVertex: Node = graph.add_vertex()
		vertex.subOf = newVertex
		vertex.type = TYPE_VERTEX.ENTRANCE
		for edge in graph.get_edges_of(vertex):
			if edge.from == vertex.name:
				edge.from = newVertex.name
			elif edge.to == vertex.name:
				edge.to = newVertex.name
		var msg = "execute rule createEntrance at " + str(vertex) +" new "+str(newVertex)
		print(msg)
		$Drawer.to_dot(graph, msg)

func _create_goal(graph: Node, vertex: Node):
	#create goal
	if vertex.type == TYPE_VERTEX.GOAL:
		var newVertex: Node = graph.add_vertex()
		vertex.subOf = newVertex
		for edge in graph.get_edges_of(vertex):
			if edge.from == vertex.name:
				edge.from = newVertex.name
			elif edge.to == vertex.name:
				edge.to = newVertex.name
		var msg = "execute rule createGoal at" + str(vertex) +" new "+str(newVertex)
		print(msg)
		$Drawer.to_dot(graph, msg)

func _create_secret(graph: Node, vertex: Node):
	#create secret
	if vertex.type == TYPE_VERTEX.SECRET:
		var newVertex: Node = graph.add_vertex()
		vertex.subOf = newVertex
		for edge in graph.get_edges_of(vertex):
			if edge.from == vertex.name:
				edge.from = newVertex.name
			elif edge.to == vertex.name:
				edge.to = newVertex.name
		var msg = "execute rule createSecret at" + str(vertex) +" new "+str(newVertex)
		print(msg)
		$Drawer.to_dot(graph, msg)

func _add_element_before_place(graph: Node):
	var matchVertices: Array = []
	for vertex1 in graph.get_vertices():
		for vertex2 in graph.get_outgoing_vertex(vertex1, TYPE_EDGE.PATH):
			if graph.is_place(vertex1) and graph.is_element(vertex2):
				matchVertices.append([vertex1, vertex2])
	# example
	if !matchVertices.empty():
		randomize()
		var choosenMatch = matchVertices[randi() % matchVertices.size()]
		choosenMatch[1].subOf = choosenMatch[0]
		for edge in graph.get_edges_of(choosenMatch[1], TYPE_EDGE.PATH):
			if edge.from == choosenMatch[0].name and edge.to == choosenMatch[1].name:
				edge.queue_free()
			elif edge.from == choosenMatch[1].name:
				var theVertex: Node = graph.get_vertex_by_name(edge.to)
				if graph.is_place(theVertex):
					edge.from = choosenMatch[0].name
				else:
					edge.type = TYPE_EDGE.ELEMENT
					graph.connect_vertex(choosenMatch[0], theVertex)
			elif edge.to == choosenMatch[1].name:
				var theVertex: Node = graph.get_vertex_by_name(edge.from)
				if graph.is_place(theVertex):
					edge.to = choosenMatch[0].name
				else:
					edge.type = TYPE_EDGE.ELEMENT
					graph.connect_vertex(theVertex, choosenMatch[0])
		var msg = "execute rule addElementBeforePlace at" + str(choosenMatch[0]) + str(choosenMatch[1])
		print(msg)
		$Drawer.to_dot(graph, msg)

func _add_lock_after_place(graph: Node):
	var matchVertices: Array = []
	for vertex1 in graph.get_vertices():
		for vertex2 in graph.get_outgoing_vertex(vertex1, TYPE_EDGE.PATH):
			if vertex1.type == TYPE_EDGE.KEY_LOCK and graph.is_place(vertex2):
				matchVertices.append([vertex1, vertex2])
	
	if matchVertices.size() > 0:
		randomize()
		var choosenMatch = matchVertices[randi() % matchVertices.size()]
		choosenMatch[0].subOf = choosenMatch[1]
		for edge in graph.get_edges_of(choosenMatch[0], TYPE_EDGE.PATH):
			if edge.from == choosenMatch[0].name and edge.to == choosenMatch[1].name:
				edge.queue_free()
			elif edge.from == choosenMatch[0].name:
				var theVertex: Node = graph.get_vertex_by_name(edge.to)
				if graph.is_place(theVertex):
					edge.from = choosenMatch[1].name
				else:
					edge.type = TYPE_EDGE.ELEMENT
					graph.connect_vertex(choosenMatch[1], theVertex)
			elif edge.to == choosenMatch[0].name:
				var theVertex: Node = graph.get_vertex_by_name(edge.from)
				if graph.is_place(theVertex):
					edge.to = choosenMatch[1].name
				else:
					edge.type = TYPE_EDGE.ELEMENT
					graph.connect_vertex(theVertex, choosenMatch[1])
		var msg = "execute rule addLockAfterPlace at" + str(choosenMatch[0]) + str(choosenMatch[1])
		print(msg)
		$Drawer.to_dot(graph, msg)

func _place_key_element(graph: Node):
	var matchVertices: Array = []
	for vertex1 in graph.get_vertices():
		for vertex2 in graph.get_outgoing_vertex(vertex1, TYPE_EDGE.PATH):
			if vertex1.type == TYPE_VERTEX.KEY and graph.is_place(vertex2):
				matchVertices.append([vertex1, vertex2])
	
	if matchVertices.size() > 0:
		randomize()
		var choosenMatch = matchVertices[randi() % matchVertices.size()]
		var newVertex: Node = graph.add_vertex()
		choosenMatch[0].subOf = newVertex
		for edge in graph.get_edges_of(choosenMatch[0], TYPE_EDGE.PATH):
			if edge.from == choosenMatch[0].name:
				var theVertex: Node = graph.get_vertex_by_name(edge.to)
				if graph.is_place(theVertex):
					edge.from = newVertex.name
				else:
					edge.type = TYPE_EDGE.ELEMENT
					graph.connect_vertex(newVertex, theVertex)
			elif edge.to == choosenMatch[0].name:
				var theVertex: Node = graph.get_vertex_by_name(edge.from)
				if graph.is_place(theVertex):
					edge.to = newVertex.name
				else:
					edge.type = TYPE_EDGE.ELEMENT
					graph.connect_vertex(theVertex, newVertex)
		var msg = "execute rule addLockAfterPlace at" + str(choosenMatch[0]) + str(choosenMatch[1])
		print(msg)
		$Drawer.to_dot(graph, msg)

func _add_element_after_place(graph: Node):
	var matchVertices: Array = []
	for vertex1 in graph.get_vertices():
		for vertex2 in graph.get_outgoing_vertex(vertex1, TYPE_EDGE.PATH):
			for vertex3 in graph.get_outgoing_vertex(vertex2, TYPE_EDGE.PATH):
				if graph.is_element(vertex1) and graph.is_element(vertex2) and graph.is_place(vertex3):
					matchVertices.append([vertex1, vertex2, vertex3])
	
	if matchVertices.size() > 0:
		randomize()
		var choosenMatch = matchVertices[randi() % matchVertices.size()]
		choosenMatch[1].subOf = choosenMatch[2]
		for edge in graph.get_edges_of(choosenMatch[1], TYPE_EDGE.PATH):
			if edge.from == choosenMatch[1].name and edge.to == choosenMatch[2].name:
				edge.queue_free()
			if edge.from == choosenMatch[1].name:
				var theVertex: Node = graph.get_vertex_by_name(edge.to)
				if graph.is_place(theVertex):
					edge.from = choosenMatch[2].name
				else:
					edge.type = TYPE_EDGE.ELEMENT
					graph.connect_vertex(choosenMatch[2], theVertex)
			elif edge.to == choosenMatch[1].name:
				var theVertex: Node = graph.get_vertex_by_name(edge.from)
				if graph.is_place(theVertex):
					edge.to = choosenMatch[2].name
				else:
					edge.type = TYPE_EDGE.ELEMENT
					graph.connect_vertex(theVertex, choosenMatch[2])
		var msg = "execute rule addLockAfterPlace at" + str(choosenMatch[0]) + str(choosenMatch[1]) + str(choosenMatch[2])
		print(msg)
		$Drawer.to_dot(graph, msg)

func _outside_element_exist(graph: Node) -> bool:
	for vertex in graph.get_vertices():
		if graph.is_element(vertex) and vertex.subOf == null:
			return true
	return false
