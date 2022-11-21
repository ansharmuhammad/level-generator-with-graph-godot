extends Node

var gridSize: Vector2 = Vector2(600,600)

func _rule_init_1(graph: Node):
	var matchEdge: Array = []
	for edge in graph.get_node("Edges").get_children():
		#check if there is init vertex
		var from = graph.get_vertex(edge.from)
		if from.type == TYPE_VERTEX.INIT and edge.to == null:
			matchEdge.append(edge)

	if matchEdge.size() > 0:
		var chosenEdge = matchEdge[randi() % matchEdge.size()]
		var vertex1 = graph.get_vertex(chosenEdge.from)
		vertex1.type = TYPE_VERTEX.START
		vertex1.labelType.text = "S"
#		var rad = vertex1.colShape.get_shape().radius * 2

		var vertex2 = graph.add_vertex()
#		vertex2.position = vertex1.position + (Vector2.RIGHT * rad)
		vertex2.position = vertex1.position + (Vector2(gridSize.x, 0))
		var vertex3 = graph.add_vertex("",TYPE_VERTEX.GOAL)
#		vertex3.position = vertex2.position + (Vector2.DOWN * rad)
		vertex3.position = vertex2.position + (Vector2(0, gridSize.y))
		var vertex4 = graph.add_vertex()
#		vertex4.position = vertex1.position + (Vector2.DOWN * rad)
		vertex4.position = vertex1.position + (Vector2(0, gridSize.y))

		chosenEdge.init_object(vertex1, vertex2)
		graph.connect_vertex(vertex2, vertex3)
		graph.connect_vertex(vertex3, vertex4)
		graph.connect_vertex(vertex4, vertex1)
#		print("execute rule init1 at" + str(chosenEdge))

func _rule_init_2(graph: Node):
	var matchEdge: Array = []
	for edge in graph.get_node("Edges").get_children():
		#check if there is init vertex
		var from = graph.get_vertex(edge.from)		
		if from.type == TYPE_VERTEX.INIT and edge.to == null:
			matchEdge.append(edge)

	if matchEdge.size() > 0:
		var chosenEdge = matchEdge[randi() % matchEdge.size()]
		var vertex1 = graph.get_vertex(chosenEdge.from)
		vertex1.type = TYPE_VERTEX.START
		vertex1.labelType.text = "S"
#		var rad = vertex1.colShape.get_shape().radius * 2
		
		var vertex2 = graph.add_vertex()
		vertex2.position = vertex1.position + (Vector2(gridSize.x, 0))
		var vertex3 = graph.add_vertex()
		vertex3.position = vertex2.position + (Vector2(gridSize.x, 0))
		var vertex4 = graph.add_vertex()
		vertex4.position = vertex3.position + (Vector2(0, gridSize.y))
		var vertex5 = graph.add_vertex("",TYPE_VERTEX.GOAL)
		vertex5.position = vertex4.position + (Vector2(gridSize.x, 0))
		var vertex6 = graph.add_vertex()
		vertex6.position = vertex4.position + (Vector2.LEFT)
		
		chosenEdge.init_object(vertex1, vertex2)
		graph.connect_vertex(vertex2, vertex3)
		graph.connect_vertex(vertex3, vertex4)
		graph.connect_vertex(vertex4, vertex5)
		graph.connect_vertex(vertex4, vertex6)
		graph.connect_vertex(vertex6, vertex2)
#		print("execute rule init2 at" + str(chosenEdge))

func _rule_extend_1(graph: Node):
	var matchEdge: Array = []
	for edge in graph.get_node("Edges").get_children():
		#check if there is 2 vertex connected
		if edge.type == TYPE_EDGE.PATH:
			matchEdge.append(edge)

	if matchEdge.size() > 0:
		var chosenEdge = matchEdge[randi() % matchEdge.size()]
		var vertex1 = graph.get_vertex(chosenEdge.from)
		var vertex2 = graph.get_vertex(chosenEdge.to)
		var vertex3 = graph.add_vertex()
		var slidePos = vertex2.position + Vector2(gridSize.x ,0).rotated(vertex2.position.angle_to_point(vertex1.position))
#		vertex2.move_to(slidePos)
#		vertex2.global_transform.origin = vertex2.position + Vector2(gridSize.x * 2 ,0).rotated(vertex2.position.angle_to_point(vertex1.position))
		vertex3.global_position = (vertex1.global_position + slidePos)/2
		
		chosenEdge.init_object(vertex1, vertex3)
		graph.connect_vertex(vertex3, vertex2)
#		print("execute rule Extend1 at" + str(chosenEdge))

func _rule_extend_2(graph: Node):
	var matchEdge: Array = []
	for edge in graph.get_node("Edges").get_children():
		#check if there is 2 vertex connected
		if edge.type == TYPE_EDGE.PATH and graph.get_edges_of(edge.from).size() < 4 and graph.get_edges_of(edge.to).size() < 4:
			matchEdge.append(edge)

	if matchEdge.size() > 0:
		var chosenEdge = matchEdge[randi() % matchEdge.size()]
		var vertex1 = graph.get_vertex(chosenEdge.from)
#		var rad = vertex1.colShape.get_shape().radius * 2
		var vertex2 = graph.get_vertex(chosenEdge.to)
		var vertex3 = graph.add_vertex()
		var vertex4 = graph.add_vertex()
		vertex4.position = vertex1.position + Vector2(gridSize.x, 0).rotated(vertex1.position.angle_to_point(vertex2.position) + deg2rad(90))
		vertex3.position = vertex2.position + Vector2(gridSize.x, 0).rotated(vertex2.position.angle_to_point(vertex1.position) + deg2rad(-90))
		
		graph.connect_vertex(vertex1, vertex4)
		graph.connect_vertex(vertex4, vertex3)
		graph.connect_vertex(vertex3, vertex2)
#		print("execute rule Extend2 at" + str(chosenEdge))

func _rule_extend_3(graph: Node):
	var matchEdge: Array = []
	for edge in graph.get_node("Edges").get_children():
		#check if there is 2 vertex connected
		var vertex1 = graph.get_vertex(edge.from)
		var vertex2 = graph.get_vertex(edge.to)
		if edge.type == TYPE_EDGE.PATH and graph.get_edges_of(vertex1).size() < 4 and graph.get_edges_of(vertex2).size() < 4:
			matchEdge.append(edge)

	if matchEdge.size() > 0:
		var chosenEdge = matchEdge[randi() % matchEdge.size()]
		var vertex1 = graph.get_vertex(chosenEdge.from)
#		var rad = vertex1.colShape.get_shape().radius * 2
		var vertex2 = graph.get_vertex(chosenEdge.to)
		var vertex3 = graph.add_vertex()
		var vertex4 = graph.add_vertex()
		vertex3.position = vertex2.position + Vector2(gridSize.x, 0).rotated(vertex2.position.angle_to_point(vertex1.position) + deg2rad(-90))
		vertex4.position = vertex1.position + Vector2(gridSize.x, 0).rotated(vertex1.position.angle_to_point(vertex2.position) + deg2rad(90))
		
		graph.connect_vertex(vertex2, vertex3)
		graph.connect_vertex(vertex3, vertex4)
		graph.connect_vertex(vertex4, vertex1)
#		print("execute rule Extend2 at" + str(chosenEdge))

func _rule_secret(graph: Node):
	var matchEdge: Array = []
	for edge in graph.get_node("Edges").get_children():
		#check if there is init vertex
		var from = graph.get_vertex(edge.from)
		var to = graph.get_vertex(edge.to)
		if ((from.type == TYPE_VERTEX.TASK and graph.get_edges_of(from).size() < 4) or (to.type == TYPE_VERTEX.TASK and graph.get_edges_of(to).size() < 4 )) and edge.type == TYPE_EDGE.PATH:
			matchEdge.append(edge)
	
	if matchEdge.size() > 0:
		var chosenEdge = matchEdge[randi() % matchEdge.size()]
		var from = graph.get_vertex(chosenEdge.from)
		var to = graph.get_vertex(chosenEdge.to)
		
		var arrayVertex: Array = []
		if from.type == TYPE_VERTEX.TASK and graph.get_edges_of(from).size() < 4:
			arrayVertex.append(from)
		if to.type == TYPE_VERTEX.TASK and graph.get_edges_of(to).size() < 4:
			arrayVertex.append(to)
		
		var idx = randi() % arrayVertex.size()
		var vertex1 = arrayVertex[idx]
#		var rad = vertex1.colShape.get_shape().radius * 2
		var vertex2 = graph.add_vertex("",TYPE_VERTEX.SECRET)
		
		if idx == 0:
			vertex2.position = from.position + Vector2(gridSize.x, 0).rotated(from.position.angle_to_point(to.position) + deg2rad(-90))
		else:
			vertex2.position = to.position + Vector2(gridSize.x, 0).rotated(to.position.angle_to_point(from.position) + deg2rad(-90))
		
		graph.connect_vertex(vertex1, vertex2)
#		print("execute rule Secret at" + str(chosenEdge) + "detail : " + vertex1.name)

func _rule_obstacle(graph: Node):
	var matchEdge: Array = []
	for edge in graph.get_node("Edges").get_children():
		#check if there is 2 vertex connected
		if edge.to != null:
			matchEdge.append(edge)
	
	if matchEdge.size() > 0:
		var chosenEdge = matchEdge[randi() % matchEdge.size()]
		var vertex1 = graph.get_vertex(chosenEdge.from)
		var vertex2 = graph.get_vertex(chosenEdge.to)
		var vertex3 = graph.add_vertex("", TYPE_VERTEX.OBSTACLE)
#		vertex2.position = vertex2.position - Vector2(gridSize,0).rotated(vertex2.position.angle_to_point(vertex1.position))
		vertex3.position = (vertex1.position + vertex2.position)/2
		
		chosenEdge.init_object(vertex1, vertex3)
		graph.connect_vertex(vertex3, vertex2)
#		print("execute rule Obstacle at" + str(chosenEdge))

func _rule_reward(graph: Node):
	var matchEdge: Array = []
	for edge in graph.get_node("Edges").get_children():
		#check if there is 2 vertex connected
		if edge.to != null:
			matchEdge.append(edge)
	
	if matchEdge.size() > 0:
		var chosenEdge = matchEdge[randi() % matchEdge.size()]
		var vertex1 = graph.get_vertex(chosenEdge.from)
		var vertex2 = graph.get_vertex(chosenEdge.to)
		var vertex3 = graph.add_vertex("", TYPE_VERTEX.OBSTACLE)
		vertex3.position = (vertex1.position + vertex2.position)/2
		var vertex4 = graph.add_vertex("", TYPE_VERTEX.REWARD)
		vertex4.position = (vertex3.position + vertex2.position)/2
		
		chosenEdge.init_object(vertex1, vertex3)
		graph.connect_vertex(vertex3, vertex4)
		graph.connect_vertex(vertex4, vertex2)
#		print("execute rule Reward at" + str(chosenEdge))

func _rule_knl_1(graph: Node):
	var matchEdge: Array = []
	for edge in graph.get_node("Edges").get_children():
		#check if there is 2 place vertex connected
		var from = graph.get_vertex(edge.from)
		var to = graph.get_vertex(edge.to)
		if graph.is_place(from) and graph.is_place(to):
			matchEdge.append(edge)
	
	if matchEdge.size() > 0:
		var chosenEdge = matchEdge[randi() % matchEdge.size()]
		var vertex1 = graph.get_vertex(chosenEdge.from)
		var vertex2 = graph.get_vertex(chosenEdge.to)
		
		var vertex3 = graph.add_vertex("", TYPE_VERTEX.KEY)
		vertex3.position = (vertex1.position + vertex2.position)/2
		var vertex4 = graph.add_vertex("", TYPE_VERTEX.TASK)
		vertex4.position = (vertex3.position + vertex2.position)/2
		var vertex5 = graph.add_vertex("", TYPE_VERTEX.LOCK)
		vertex5.position = (vertex4.position + vertex2.position)/2
		
		chosenEdge.init_object(vertex1, vertex3)
		graph.connect_vertex(vertex3, vertex4)
		graph.connect_vertex(vertex4, vertex5)
		graph.connect_vertex(vertex5, vertex2)
		
		graph.connect_vertex(vertex3, vertex5, TYPE_EDGE.KEY_LOCK)
#		print("execute rule KL1 at" + str(edge))

func _rule_knl_2(graph: Node):
	var matchEdge: Array = []
	for edge in graph.get_node("Edges").get_children():
		#check if there is 2 vertex connected
		if edge.to != null and graph.get_edges_of(edge.from).size() < 4 and graph.get_edges_of(edge.to).size() < 4:
			matchEdge.append(edge)
	
	if matchEdge.size() > 0:
		var chosenEdge = matchEdge[randi() % matchEdge.size()]
		var vertex1 = graph.get_vertex(chosenEdge.from)
		var vertex2 = graph.get_vertex(chosenEdge.to)
#		var rad = vertex1.colShape.get_shape().radius * 2
		
		var vertex3 = graph.add_vertex("", TYPE_VERTEX.TASK)
		vertex3.position = (vertex1.position + vertex2.position)/2
		var vertex4 = graph.add_vertex("", TYPE_VERTEX.LOCK)
		vertex4.position = (vertex3.position + vertex2.position)/2
		var vertex5 = graph.add_vertex("", TYPE_VERTEX.KEY)
		vertex5.position = vertex3.position + Vector2(gridSize.x, 0).rotated(vertex3.position.angle_to_point(vertex1.position) + deg2rad(-90))
		var vertex6 = graph.add_vertex("", TYPE_VERTEX.TASK)
		vertex6.position = vertex1.position + Vector2(gridSize.x, 0).rotated(vertex1.position.angle_to_point(vertex3.position) + deg2rad(90))
		
		chosenEdge.init_object(vertex1, vertex3)
		graph.connect_vertex(vertex3, vertex4)
		graph.connect_vertex(vertex1, vertex6)
		graph.connect_vertex(vertex6, vertex5)
		graph.connect_vertex(vertex5, vertex3)
		
		graph.connect_vertex(vertex4, vertex2)
		graph.connect_vertex(vertex5, vertex4, TYPE_EDGE.KEY_LOCK)
#		print("execute rule KL2 at" + str(chosenEdge))

func _rule_knl_3(graph: Node):
	var matchEdge: Array = []
	for edge in graph.get_node("Edges").get_children():
		#check if there is 2 vertex connected
		if edge.to != null and graph.get_edges_of(edge.from).size() < 4 and graph.get_edges_of(edge.to).size() < 4:
			matchEdge.append(edge)
	
	if matchEdge.size() > 0:
		var chosenEdge = matchEdge[randi() % matchEdge.size()]
		var vertex1 = graph.get_vertex(chosenEdge.from)
#		var rad = vertex1.colShape.get_shape().radius * 2
		var vertex2 = graph.get_vertex(chosenEdge.to)
		
		var vertex3 = graph.add_vertex("", TYPE_VERTEX.TASK)
		vertex3.position = (vertex1.position + vertex2.position)/2
		var vertex4 = graph.add_vertex("", TYPE_VERTEX.LOCK)
		vertex4.position = (vertex3.position + vertex2.position)/2
		var vertex5 = graph.add_vertex("", TYPE_VERTEX.TASK)
		vertex5.position = vertex3.position + Vector2(gridSize.x, 0).rotated(vertex3.position.angle_to_point(vertex1.position) + deg2rad(-90))
		var vertex6 = graph.add_vertex("", TYPE_VERTEX.KEY)
		vertex6.position = vertex1.position + Vector2(gridSize.x, 0).rotated(vertex1.position.angle_to_point(vertex3.position) + deg2rad(90))
		
		chosenEdge.init_object(vertex1, vertex3)
		graph.connect_vertex(vertex3, vertex4)
		graph.connect_vertex(vertex3, vertex5)
		graph.connect_vertex(vertex5, vertex6)
		graph.connect_vertex(vertex6, vertex1)
		
		graph.connect_vertex(vertex4, vertex2)
		graph.connect_vertex(vertex6, vertex4, TYPE_EDGE.KEY_LOCK)
#		print("execute rule KL3 at" + str(chosenEdge))

func _rule_knl_4(graph: Node):
	var matchEdge: Array = []
	for edge in graph.get_node("Edges").get_children():
		#check if there is 2 vertex connected and the secon vertex type is goal
		var from = graph.get_vertex(edge.from)
		var to = graph.get_vertex(edge.to)
		if graph.is_place(from) and to.type == TYPE_VERTEX.GOAL:
			matchEdge.append(edge)
	
	if matchEdge.size() > 0:
		var chosenEdge = matchEdge[randi() % matchEdge.size()]
		var vertex1 = graph.get_vertex(chosenEdge.from)
		var vertex2 = graph.get_vertex(chosenEdge.to)
		
		var vertex3 = graph.add_vertex("", TYPE_VERTEX.KEY)
		vertex3.position = (vertex1.position + vertex2.position)/2
		var vertex4 = graph.add_vertex("", TYPE_VERTEX.TASK)
		vertex4.position = (vertex3.position + vertex2.position)/2
		var vertex5 = graph.add_vertex("", TYPE_VERTEX.LOCK)
		vertex5.position = (vertex4.position + vertex2.position)/2
		
		chosenEdge.init_object(vertex1, vertex3)
		graph.connect_vertex(vertex3, vertex4)
		graph.connect_vertex(vertex4, vertex5)
		graph.connect_vertex(vertex5, vertex2)
		
		graph.connect_vertex(vertex3, vertex5, TYPE_EDGE.KEY_LOCK)
#		print("execute rule KL4 at" + str(chosenEdge))

