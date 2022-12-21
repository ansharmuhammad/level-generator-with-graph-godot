extends Node

func sub_off(vertex: Node2D, sub_vertex: Node2D):
	sub_vertex.subOf = vertex
	sub_vertex.connection_reset()
	vertex.subs.append(sub_vertex)
	var graph: Node = vertex.get_parent().get_parent()
#	vertex.add_to_group("placeVertices" + graph.name)
#	sub_vertex.add_to_group("subVertices" + graph.name)
	#positioning sub vertices
	for i in range(vertex.subs.size()):
		var sub: Node2D = vertex.subs[i]
		sub.position = vertex.position + Vector2(32 + 16,0).rotated(deg2rad(i * 36))

func duplicate_key(graph: Node2D):
	var matchEdge: Array = []
	for edge in graph.get_edges():
		#check if there is init vertex
		if edge.from.type == TYPE_VERTEX.KEY and edge.to.type == TYPE_VERTEX.LOCK:
			matchEdge.append(edge)
	
	if matchEdge.size() > 0:
		var chosenEdge: Node2D = matchEdge[randi() % matchEdge.size()]
		var vertex1: Node2D = chosenEdge.from
		var vertex2: Node2D = chosenEdge.to
		var vertex3: Node2D = graph.add_vertex("",TYPE_VERTEX.KEY)
		
		sub_off(vertex1.subOf, vertex3)
		
		graph.connect_vertex(vertex3, vertex2, TYPE_EDGE.KEY_LOCK)

func duplicate_lock(graph: Node2D):
	var matchEdge: Array = []
	for edge in graph.get_edges():
		#check if there is init vertex
		if edge.from.type == TYPE_VERTEX.KEY and edge.to.type == TYPE_VERTEX.LOCK:
			matchEdge.append(edge)
	
	if matchEdge.size() > 0:
		var chosenEdge: Node2D = matchEdge[randi() % matchEdge.size()]
		var vertex1: Node2D = chosenEdge.from
		var vertex2: Node2D = chosenEdge.to
		var vertex3: Node2D = graph.add_vertex("",TYPE_VERTEX.LOCK)
		
		sub_off(vertex2.subOf, vertex3)
		
		graph.connect_vertex(vertex1, vertex3, TYPE_EDGE.KEY_LOCK)

func move_lock_toward(graph: Node2D):
	var matchEdge: Array = []
	for edge in graph.get_edges():
		#check if there is init vertex
		if edge.from.type == TYPE_VERTEX.KEY and edge.to.type == TYPE_VERTEX.LOCK:
			matchEdge.append(edge)
	
	if matchEdge.size() > 0:
		var chosenEdge: Node2D = matchEdge[randi() % matchEdge.size()]
		var vertex1: Node2D = chosenEdge.to
		
		var candidatePlace: Array =  graph.get_outgoing_vertex(vertex1.subOf)
		if candidatePlace.size() > 0:
			var chosenPlace: Node2D = candidatePlace[randi() % candidatePlace.size()]
			vertex1.subOf.subs.erase(vertex1)
			sub_off(chosenPlace, vertex1)

func move_key_duplicate_backward(graph: Node2D):
	var matchEdge: Array = []
	for edge in graph.get_edges():
		#check if there is init vertex
		var matchCandidate: Array = []
		if edge.from.type == TYPE_VERTEX.KEY and edge.to.type == TYPE_VERTEX.LOCK:
			if graph.get_incoming_vertex(edge.to).size() > 1:
				matchEdge.append(edge)
	
	if matchEdge.size() > 0:
		var chosenEdge: Node2D = matchEdge[randi() % matchEdge.size()]
		var chosenKey: Node2D = graph.get_incoming_vertex(chosenEdge.to).back()
		var candidatePlace: Array =  graph.get_incoming_vertex(chosenKey.subOf)
		if candidatePlace.size() > 0:
			var chosenPlace: Node2D = candidatePlace[randi() % candidatePlace.size()]
			chosenKey.subOf.subs.erase(chosenKey)
			sub_off(chosenPlace, chosenKey)
