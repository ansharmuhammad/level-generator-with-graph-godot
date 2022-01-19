extends Control

export onready var population: int = 3

const Graph = preload("res://generator/graph/Graph.tscn")

func _ready():
	running()

func running():
	var graph: Node = _generate(population)
	var result = graph.duplicate()
	result.name = "GrapResult"
	$Result.add_child(result)
	_transform(result)
	$Drawer.to_dot(result)

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
	return $Graphs.get_child(0)

func _transform(graph: Node):
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
	
	return graph

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
		print("execute rule createEntrance at" + str(vertex))
		print("new "+str(newVertex))

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
		print("execute rule createGoal at" + str(vertex))
		print("new "+str(newVertex))

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
		print("execute rule createSecret at" + str(vertex))
		print("new "+str(newVertex))

func _add_element_before_place(graph: Node):
	var matchVertices: Array = []
	for vertex1 in graph.get_vertices():
		for vertex2 in graph.get_outgoing_vertex(vertex1, TYPE_EDGE.PATH):
			if graph.is_place(vertex1) and graph.is_element(vertex2):
				matchVertices.append([vertex1, vertex2])
	
	if !matchVertices.empty():
		randomize()
		var choosenMatch = matchVertices[randi() % matchVertices.size()]
		choosenMatch[1].subOf = choosenMatch[0]
		for edge in graph.get_edges_of(choosenMatch[1], TYPE_EDGE.PATH):
			if edge.from == choosenMatch[0].name and edge.to == choosenMatch[1].name:
				edge.queue_free()
			elif edge.from == choosenMatch[1].name:
				edge.from = choosenMatch[0].name
			elif edge.to == choosenMatch[1].name:
				edge.to = choosenMatch[0].name
		print("execute rule addElementBeforePlace at" + str(choosenMatch[0]) + str(choosenMatch[1]))

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
				edge.from = choosenMatch[1].name
			elif edge.to == choosenMatch[0].name:
				edge.to = choosenMatch[1].name
		print("execute rule addLockAfterPlace at" + str(choosenMatch[0]) + str(choosenMatch[1]))

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
				edge.from = newVertex.name
			elif edge.to == choosenMatch[0].name:
				edge.to = newVertex.name
		print("execute rule addLockAfterPlace at" + str(choosenMatch[0]) + str(choosenMatch[1]))

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
				edge.from = choosenMatch[2].name
			elif edge.to == choosenMatch[1].name:
				edge.to = choosenMatch[2].name
		print("execute rule addLockAfterPlace at" + str(choosenMatch[0]) + str(choosenMatch[1]) + str(choosenMatch[2]))

func _outside_element_exist(graph: Node) -> bool:
	for vertex in graph.get_vertices():
		if graph.is_element(vertex) and vertex.subOf == null:
			return true
	return false
