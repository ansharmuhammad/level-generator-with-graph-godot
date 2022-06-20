extends Node
#get drawer node from root main
onready var Drawer = get_parent().get_node("Drawer")

func transform(graph: Node):
	Drawer.to_dot(graph)
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
		#(msg)
		Drawer.to_dot(graph, msg)

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
		#(msg)
		Drawer.to_dot(graph, msg)

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
		#(msg)
		Drawer.to_dot(graph, msg)

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
		#(msg)
		Drawer.to_dot(graph, msg)

func _add_lock_after_place(graph: Node):
	var matchVertices: Array = []
	for vertex1 in graph.get_vertices():
		for vertex2 in graph.get_outgoing_vertex(vertex1, TYPE_EDGE.PATH):
			if vertex1.type == TYPE_VERTEX.LOCK and graph.is_place(vertex2):
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
		#(msg)
		Drawer.to_dot(graph, msg)

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
		#(msg)
		Drawer.to_dot(graph, msg)

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
		#(msg)
		Drawer.to_dot(graph, msg)

func _outside_element_exist(graph: Node) -> bool:
	for vertex in graph.get_vertices():
		if graph.is_element(vertex) and vertex.subOf == null:
			return true
	return false

