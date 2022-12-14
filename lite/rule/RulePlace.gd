extends Node

var cellSize: Vector2 = Vector2(256,256)
const DIRECTIONS = [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]

func sub_off(vertex: Node2D, sub_vertex: Node2D):
	sub_vertex.subOf = vertex
	sub_vertex.connection_reset()
	vertex.subs.append(sub_vertex)
	var graph: Node = vertex.get_parent().get_parent()
	vertex.add_to_group("placeVertices" + graph.name)
	sub_vertex.add_to_group("subVertices" + graph.name)
	#positioning sub vertices
	for i in range(vertex.subs.size()):
		var sub: Node2D = vertex.subs[i]
		sub.position = vertex.position + Vector2(32 + 16,0).rotated(deg2rad(i * 36))

func create_entrance(graph: Node2D, vertex: Node2D):
	#create entrance
	if vertex.type == TYPE_VERTEX.START:
		var newVertex: Node2D = graph.add_vertex()
		newVertex.add_to_group("placeVertices" + graph.name)
		graph.change_vertex_pos(newVertex, vertex.position)
		vertex.type = TYPE_VERTEX.ENTRANCE
		sub_off(newVertex, vertex)
		for edge in graph.get_edges_of(vertex):
			if edge.from == vertex:
				edge.from = newVertex
			elif edge.to == vertex:
				edge.to = newVertex
		newVertex.connections = vertex.connections.duplicate()
#		var msg = "execute rule createEntrance at " + str(vertex) +" new "+str(newVertex)
#		print(msg)

func create_goal(graph: Node2D, vertex: Node2D):
	#create goal
	if vertex.type == TYPE_VERTEX.GOAL:
		var newVertex: Node2D = graph.add_vertex()
		newVertex.add_to_group("placeVertices" + graph.name)
		graph.change_vertex_pos(newVertex, vertex.position)
		sub_off(newVertex, vertex)
		for edge in graph.get_edges_of(vertex):
			if edge.from == vertex:
				edge.from = newVertex
			elif edge.to == vertex:
				edge.to = newVertex
		newVertex.connections = vertex.connections.duplicate()
#		var msg = "execute rule createGoal at" + str(vertex) +" new "+str(newVertex)
#		print(msg)

func create_secret(graph: Node2D, vertex: Node2D):
	#create secret
	if vertex.type == TYPE_VERTEX.SECRET:
		var newVertex: Node2D = graph.add_vertex()
		newVertex.add_to_group("placeVertices" + graph.name)
		graph.change_vertex_pos(newVertex, vertex.position)
		sub_off(newVertex, vertex)
		for edge in graph.get_edges_of(vertex):
			if edge.from == vertex:
				edge.from = newVertex
			elif edge.to == vertex:
				edge.to = newVertex
#			edge.type = TYPE_EDGE.HIDDEN
		newVertex.connections = vertex.connections.duplicate()
#		var msg = "execute rule createSecret at" + str(vertex) +" new "+str(newVertex)
#		print(msg)

func outside_element_exist(graph: Node2D) -> bool:
	for vertex in graph.get_vertices():
		if vertex.is_element() and vertex.subOf == null:
			return true
	return false

func add_element_before_place(graph: Node2D):
	var matchVertices: Array = []
	for vertex0 in graph.get_vertices():
		for vertex1 in graph.get_outgoing_vertex(vertex0, TYPE_EDGE.PATH):
			if !vertex0.is_element() and vertex1.is_element() and vertex1.subOf == null:
				matchVertices.append([vertex0, vertex1])
	# example
	if !matchVertices.empty():
		var choosenMatch = matchVertices[randi() % matchVertices.size()]
		sub_off(choosenMatch[0], choosenMatch[1])
		for edge in graph.get_edges_of(choosenMatch[1], TYPE_EDGE.PATH):
			if edge.from == choosenMatch[0] and edge.to == choosenMatch[1]:
				edge.queue_free()
			elif edge.from == choosenMatch[1]:
				var theVertex: Node2D = edge.to
				if !theVertex.is_element():
					edge.from = choosenMatch[0]
				else:
					edge.type = TYPE_EDGE.ELEMENT
					graph.connect_vertex(choosenMatch[0], theVertex)
			elif edge.to == choosenMatch[1]:
				var theVertex: Node2D = edge.from
				if !theVertex.is_element():
					edge.to = choosenMatch[0]
				else:
					edge.type = TYPE_EDGE.ELEMENT
					graph.connect_vertex(theVertex, choosenMatch[0])
#		var msg = "execute rule addElementBeforePlace at" + str(choosenMatch[0]) + str(choosenMatch[1])
#		print(msg)

func add_lock_after_place(graph: Node2D):
	var matchVertices: Array = []
	for vertex0 in graph.get_vertices():
		for vertex1 in graph.get_outgoing_vertex(vertex0, TYPE_EDGE.PATH):
			if vertex0.type == TYPE_VERTEX.LOCK and vertex0.subOf == null and !vertex1.is_element():
				matchVertices.append([vertex0, vertex1])
	
	if matchVertices.size() > 0:
		var choosenMatch = matchVertices[randi() % matchVertices.size()]
		sub_off(choosenMatch[1], choosenMatch[0])
		for edge in graph.get_edges_of(choosenMatch[0], TYPE_EDGE.PATH):
			if edge.from == choosenMatch[0] and edge.to == choosenMatch[1]:
				edge.queue_free()
			elif edge.from == choosenMatch[0]:
				var theVertex: Node2D = edge.to
				if !theVertex.is_element():
					edge.from = choosenMatch[1]
				else:
					edge.type = TYPE_EDGE.ELEMENT
					graph.connect_vertex(choosenMatch[1], theVertex)
			elif edge.to == choosenMatch[0]:
				var theVertex: Node2D = edge.from
				if !theVertex.is_element():
					edge.to = choosenMatch[1]
				else:
					edge.type = TYPE_EDGE.ELEMENT
					graph.connect_vertex(theVertex, choosenMatch[1])
#		var msg = "execute rule addLockAfterPlace at" + str(choosenMatch[0]) + str(choosenMatch[1])
#		print(msg)

func place_key_element(graph: Node2D):
	var matchVertices: Array = []
	for vertex0 in graph.get_vertices():
		for vertex1 in graph.get_outgoing_vertex(vertex0, TYPE_EDGE.PATH):
			if vertex0.type == TYPE_VERTEX.KEY and vertex0.subOf == null and !vertex1.is_element():
				matchVertices.append([vertex0, vertex1])
	
	if matchVertices.size() > 0:
		var choosenMatch = matchVertices[randi() % matchVertices.size()]
		var newVertex: Node2D = graph.add_vertex()
		newVertex.add_to_group("placeVertices" + graph.name)
		graph.change_vertex_pos(newVertex, choosenMatch[0].position)
		sub_off(newVertex, choosenMatch[0])
		for edge in graph.get_edges_of(choosenMatch[0], TYPE_EDGE.PATH):
			if edge.from == choosenMatch[0]:
				var theVertex: Node2D = edge.to
				if !theVertex.is_element():
					edge.from = newVertex
				else:
					edge.type = TYPE_EDGE.ELEMENT
					graph.connect_vertex(newVertex, theVertex)
			elif edge.to == choosenMatch[0]:
				var theVertex: Node2D = edge.from
				if !theVertex.is_element():
					edge.to = newVertex
				else:
					edge.type = TYPE_EDGE.ELEMENT
					graph.connect_vertex(theVertex, newVertex)
#		var msg = "execute rule addLockAfterPlace at" + str(choosenMatch[0]) + str(choosenMatch[1])
#		print(msg)

func add_element_after_place(graph: Node2D):
	var matchVertices: Array = []
	for vertex0 in graph.get_vertices():
		for vertex1 in graph.get_outgoing_vertex(vertex0, TYPE_EDGE.PATH):
			for vertex2 in graph.get_outgoing_vertex(vertex1, TYPE_EDGE.PATH):
				if vertex0.is_element() and vertex1.is_element() and vertex1.subOf == null and !vertex2.is_element():
					matchVertices.append([vertex0, vertex1, vertex2])
	
	if matchVertices.size() > 0:
		var choosenMatch = matchVertices[randi() % matchVertices.size()]
		sub_off(choosenMatch[2], choosenMatch[1])
		for edge in graph.get_edges_of(choosenMatch[1], TYPE_EDGE.PATH):
			if edge.from == choosenMatch[1] and edge.to == choosenMatch[2]:
				edge.queue_free()
			if edge.from == choosenMatch[1]:
				var theVertex: Node2D = edge.to
				if !theVertex.is_element():
					edge.from = choosenMatch[2]
				else:
					edge.type = TYPE_EDGE.ELEMENT
					graph.connect_vertex(choosenMatch[2], theVertex)
			elif edge.to == choosenMatch[1]:
				var theVertex: Node2D = edge.from
				if !theVertex.is_element():
					edge.to = choosenMatch[2]
				else:
					edge.type = TYPE_EDGE.ELEMENT
					graph.connect_vertex(theVertex, choosenMatch[2])
#		var msg = "execute rule addLockAfterPlace at" + str(choosenMatch[0]) + str(choosenMatch[1]) + str(choosenMatch[2])
#		print(msg)

func create_place_rule(graph: Node2D):
	#create place rule
	for vertex in graph.get_vertices():
		create_entrance(graph, vertex)
		create_goal(graph, vertex)
		create_secret(graph, vertex)

func clean_outside_element_rule(graph: Node2D):
	#clean outside element rule
	while outside_element_exist(graph):
		var execute: int = randi() % 4
		match execute:
			0: add_element_before_place(graph)
			1: add_lock_after_place(graph)
			2: place_key_element(graph)
			3: add_lock_after_place(graph)

func make_edges_element(graph: Node2D):
	#make element edge
	for edge in graph.get_edges():
		var from: Node2D = edge.from
		var to: Node2D = edge.to
		if (from.type != TYPE_VERTEX.KEY and to.type != TYPE_VERTEX.LOCK) and (from.is_element() or to.is_element()):
				edge.type = TYPE_EDGE.ELEMENT
				edge.add_to_group("elementEdges")

func make_room_and_cave(graph: Node2D):
	#make element edge
	for edge in graph.get_edges():
		var from: Node2D = edge.from
		var to: Node2D = edge.to
		if from.type != TYPE_VERTEX.KEY and to.type != TYPE_VERTEX.LOCK:
			if from.is_element() or to.is_element():
				edge.type = TYPE_EDGE.ELEMENT
				edge.add_to_group("elementEdges")
	
	var lowestPos: Vector2 = Vector2(10000,10000) * cellSize
	var highestPos: Vector2 = Vector2(-10000,-10000) * cellSize
	var placeVertices: Array = get_tree().get_nodes_in_group("placeVertices" + graph.name)
	for vertex in placeVertices:
		#clean connections
		vertex.connections = {
			Vector2.UP: null,
			Vector2.DOWN: null,
			Vector2.LEFT: null,
			Vector2.RIGHT: null
		}
		
		#change task to room or cave
		var percent = randf()
		if (percent > 0.5):
			vertex.type = TYPE_VERTEX.ROOM
		else:
			vertex.type = TYPE_VERTEX.CAVE
		
		#get lowest x and y
		if vertex.position.x < lowestPos.x:
			lowestPos.x = vertex.position.x
		if vertex.position.y < lowestPos.y:
			lowestPos.y = vertex.position.y
		#get highest x and y
		if vertex.position.x > highestPos.x:
			highestPos.x = vertex.position.x
		if vertex.position.y > highestPos.y:
			highestPos.y = vertex.position.y
	
	#rearrange position
	#x position
	while highestPos.x >= lowestPos.x:
		var found: bool = true
		for vertex in placeVertices:
			if highestPos.x == vertex.position.x:
				found = false
				break
		if found:
			for vertex in placeVertices:
				if vertex.position.x > highestPos.x:
					vertex.position.x -= (1 * cellSize.x)
		highestPos.x -= (1 * cellSize.x)
	#y position
	while highestPos.y >= lowestPos.y:
		var found: bool = true
		for vertex in placeVertices:
			if highestPos.y == vertex.position.y:
				found = false
				break
		if found:
			for vertex in placeVertices:
				if vertex.position.y > highestPos.y:
					vertex.position.y -= (1 * cellSize.y)
		highestPos.y -= (1 * cellSize.y)
	
	#sync subvertices pos
	for subVertex in get_tree().get_nodes_in_group("subVertices" + graph.name):
		subVertex.position = subVertex.subOf.position + Vector2(32 + 16,0).rotated(deg2rad(subVertex.subOf.subs.find(subVertex) * 36))
		subVertex.connections = {
			Vector2.UP: null,
			Vector2.DOWN: null,
			Vector2.LEFT: null,
			Vector2.RIGHT: null
		}
	
	#re-connections vertex
	for edge in graph.get_edges():
		var allowType: Array = [TYPE_EDGE.PATH, TYPE_EDGE.HIDDEN, TYPE_EDGE.WINDOW, TYPE_EDGE.GATE]
		if allowType.has(edge.type) and edge.from != null and edge.to != null:
			var direction: Vector2 = edge.from.position.direction_to(edge.to.position)
			#non diagonal direction
			if DIRECTIONS.has(direction):
				var mirror = Vector2(direction.x * -1, direction.y) if direction.x != 0 else Vector2(direction.x, direction.y * -1)
				edge.from.connections[direction] = edge.to
				edge.to.connections[mirror] = edge.from
			else:
				#northeast
				if direction.x >= 0 and direction.y < 0:
					#up right
					if edge.from.connections[Vector2.UP] == null and edge.to.connections[Vector2.LEFT] == null and graph.get_vertex_by_position(Vector2(edge.from.position.x, edge.to.position.y)) == null:
						_connect_diagonal(graph, edge, Vector2(edge.from.position.x, edge.to.position.y), Vector2.UP, Vector2.RIGHT)
					#right up
					elif edge.from.connections[Vector2.RIGHT] == null and edge.to.connections[Vector2.DOWN] == null and graph.get_vertex_by_position(Vector2(edge.to.position.x, edge.from.position.y)) == null:
						_connect_diagonal(graph, edge, Vector2(edge.to.position.x, edge.from.position.y), Vector2.RIGHT, Vector2.UP)
				#southeast
				elif direction.x >= 0 and direction.y >= 0:
					#down right
					if edge.from.connections[Vector2.DOWN] == null and edge.to.connections[Vector2.LEFT] == null and graph.get_vertex_by_position(Vector2(edge.from.position.x, edge.to.position.y)) == null:
						_connect_diagonal(graph, edge, Vector2(edge.from.position.x, edge.to.position.y), Vector2.DOWN, Vector2.RIGHT)
					#right down
					elif edge.from.connections[Vector2.RIGHT] == null and edge.to.connections[Vector2.UP] == null and graph.get_vertex_by_position(Vector2(edge.to.position.x, edge.from.position.y)) == null:
						_connect_diagonal(graph, edge, Vector2(edge.to.position.x, edge.from.position.y), Vector2.RIGHT, Vector2.DOWN)
				#southwest
				elif direction.x < 0 and direction.y >= 0:
					#down left
					if edge.from.connections[Vector2.DOWN] == null and edge.to.connections[Vector2.RIGHT] == null and graph.get_vertex_by_position(Vector2(edge.from.position.x, edge.to.position.y)) == null:
						_connect_diagonal(graph, edge, Vector2(edge.from.position.x, edge.to.position.y), Vector2.DOWN, Vector2.LEFT)
					#left down
					elif edge.from.connections[Vector2.LEFT] == null and edge.to.connections[Vector2.UP] == null and graph.get_vertex_by_position(Vector2(edge.to.position.x, edge.from.position.y)) == null:
						_connect_diagonal(graph, edge, Vector2(edge.to.position.x, edge.from.position.y), Vector2.LEFT, Vector2.DOWN)
				#northwest
				elif direction.x < 0 and direction.y < 0:
					#up left
					if edge.from.connections[Vector2.UP] == null and edge.to.connections[Vector2.RIGHT] == null and graph.get_vertex_by_position(Vector2(edge.from.position.x, edge.to.position.y)) == null:
						_connect_diagonal(graph, edge, Vector2(edge.from.position.x, edge.to.position.y), Vector2.UP, Vector2.LEFT)
					#left up
					elif edge.from.connections[Vector2.LEFT] == null and edge.to.connections[Vector2.DOWN] == null and graph.get_vertex_by_position(Vector2(edge.to.position.x, edge.from.position.y)) == null:
						_connect_diagonal(graph, edge, Vector2(edge.to.position.x, edge.from.position.y), Vector2.LEFT, Vector2.UP)

func _connect_diagonal(graph: Node2D, edge: Node2D, connectorPos: Vector2, fromDirection: Vector2, toDirection: Vector2):
	var tempWeight: int = edge.weight
	var newVertex: Node2D = graph.add_vertex("", TYPE_VERTEX.CONNECTOR)
	newVertex.position = connectorPos
	var edge2: Node2D = graph.connect_vertex(newVertex, edge.to, TYPE_EDGE.PATH, toDirection)
	edge2.weight = edge.weight
	edge.init_object(edge.from, newVertex, TYPE_EDGE.PATH, fromDirection)
	edge.weight = edge.weight

func make_hidden_path(graph: Node2D):
	var placeVertices: Array = get_tree().get_nodes_in_group("placeVertices" + graph.name)
	for placeVertex in placeVertices:
		#make edge hidden
		for sub in placeVertex.subs:
			if sub.type == TYPE_VERTEX.SECRET:
				for edge in graph.get_edges_of(placeVertex):
					edge.type = TYPE_EDGE.HIDDEN

func make_window(graph: Node2D):
	var placeVertices: Array = get_tree().get_nodes_in_group("placeVertices" + graph.name)
	for placeVertex in placeVertices:
		#make edge window
		for directionUnconnected in placeVertex.connections.keys():
			var targetPos: Vector2 = placeVertex.position + (directionUnconnected * cellSize)
			var targetVertex: Node = graph.get_vertex_by_position(targetPos)
			if placeVertex.connections[directionUnconnected] == null and targetVertex != null:
				var mirror: Vector2 = Vector2(directionUnconnected.x * -1, directionUnconnected.y) if directionUnconnected.x != 0 else Vector2(directionUnconnected.x, directionUnconnected.y * -1)
				var mirrorVertex: Node = graph.get_vertex_by_position(targetVertex.position + (mirror * cellSize))
				if targetVertex.connections[mirror] == null and !targetVertex.is_element():
					graph.connect_vertex(targetVertex, placeVertex, TYPE_EDGE.WINDOW, mirror)

func make_gate(graph: Node2D):
	for edge in graph.get_edges():
		if edge.type == TYPE_EDGE.PATH:
			#change task to room or cave
			var percent = randf()
			if (percent < 0.75):
				edge.type = TYPE_EDGE.GATE
