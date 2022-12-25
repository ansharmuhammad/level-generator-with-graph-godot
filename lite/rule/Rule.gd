extends Node

var cellSize: Vector2 = Vector2(256,256)
const DIRECTIONS = [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]

func rule_init_linear(graph: Node2D):
	var matchEdge: Array = []
	for edge in graph.get_edges():
		#check if there is init vertex
		if edge.from.type == TYPE_VERTEX.INIT and edge.to == null:
			matchEdge.append(edge)

	if matchEdge.size() > 0:
		var chosenEdge: Node2D = matchEdge[randi() % matchEdge.size()]
		var vertex1: Node2D = chosenEdge.from
		var vertex2: Node2D = graph.add_vertex()
		var vertex3: Node2D = graph.add_vertex("",TYPE_VERTEX.GOAL)
		
		vertex2.add_to_group("placeVertices" + graph.name)
		
		vertex1.type = TYPE_VERTEX.START
		graph.change_vertex_pos(vertex2, vertex1.position + (Vector2.RIGHT * cellSize))
		graph.change_vertex_pos(vertex3, vertex2.position + (Vector2.RIGHT * cellSize))
		
		chosenEdge.init_object(vertex1, vertex2, TYPE_EDGE.PATH, Vector2.RIGHT)
		graph.connect_vertex(vertex2, vertex3, TYPE_EDGE.PATH, Vector2.RIGHT)

func rule_init_1(graph: Node2D):
	var matchEdge: Array = []
	for edge in graph.get_edges():
		#check if there is init vertex
		if edge.from.type == TYPE_VERTEX.INIT and edge.to == null:
			matchEdge.append(edge)

	if matchEdge.size() > 0:
		var chosenEdge: Node2D = matchEdge[randi() % matchEdge.size()]
		var vertex1: Node2D = chosenEdge.from
		var vertex2: Node2D = graph.add_vertex()
		var vertex3: Node2D = graph.add_vertex("",TYPE_VERTEX.GOAL)
		var vertex4: Node2D = graph.add_vertex()
		
		vertex2.add_to_group("placeVertices" + graph.name)
		vertex4.add_to_group("placeVertices" + graph.name)
		
		vertex1.type = TYPE_VERTEX.START
		graph.change_vertex_pos(vertex2, vertex1.position + (Vector2.RIGHT * cellSize))
		graph.change_vertex_pos(vertex3, vertex2.position + (Vector2.DOWN * cellSize))
		graph.change_vertex_pos(vertex4, vertex1.position + (Vector2.DOWN * cellSize))
		
		chosenEdge.init_object(vertex1, vertex2, TYPE_EDGE.PATH, Vector2.RIGHT)
		graph.connect_vertex(vertex2, vertex3, TYPE_EDGE.PATH, Vector2.DOWN)
		graph.connect_vertex(vertex3, vertex4, TYPE_EDGE.PATH, Vector2.LEFT)
		graph.connect_vertex(vertex4, vertex1, TYPE_EDGE.PATH, Vector2.UP)
#		print("execute rule init1 at" + str(chosenEdge))

func rule_init_2(graph: Node2D):
	var matchEdge: Array = []
	for edge in graph.get_edges():
		#check if there is init vertex
		if edge.from.type == TYPE_VERTEX.INIT and edge.to == null:
			matchEdge.append(edge)

	if matchEdge.size() > 0:
		var chosenEdge = matchEdge[randi() % matchEdge.size()]
		var vertex1: Node2D = chosenEdge.from
		var vertex2: Node2D = graph.add_vertex()
		var vertex3: Node2D = graph.add_vertex()
		var vertex4: Node2D = graph.add_vertex()
		var vertex5: Node2D = graph.add_vertex("",TYPE_VERTEX.GOAL)
		var vertex6: Node2D = graph.add_vertex()
		
		vertex2.add_to_group("placeVertices" + graph.name)
		vertex3.add_to_group("placeVertices" + graph.name)
		vertex4.add_to_group("placeVertices" + graph.name)
		vertex6.add_to_group("placeVertices" + graph.name)
		
		vertex1.type = TYPE_VERTEX.START
		graph.change_vertex_pos(vertex2, vertex1.position + Vector2.RIGHT * cellSize)
		graph.change_vertex_pos(vertex3, vertex2.position + Vector2.RIGHT * cellSize)
		graph.change_vertex_pos(vertex4, vertex3.position + Vector2.DOWN * cellSize)
		graph.change_vertex_pos(vertex5, vertex4.position + Vector2.RIGHT * cellSize)
		graph.change_vertex_pos(vertex6, vertex4.position + Vector2.LEFT * cellSize)
		
		chosenEdge.init_object(vertex1, vertex2, TYPE_EDGE.PATH, Vector2.RIGHT)
		graph.connect_vertex(vertex2, vertex3, TYPE_EDGE.PATH, Vector2.RIGHT)
		graph.connect_vertex(vertex3, vertex4, TYPE_EDGE.PATH, Vector2.DOWN)
		graph.connect_vertex(vertex4, vertex5, TYPE_EDGE.PATH, Vector2.RIGHT)
		graph.connect_vertex(vertex4, vertex6, TYPE_EDGE.PATH, Vector2.LEFT)
		graph.connect_vertex(vertex6, vertex2, TYPE_EDGE.PATH, Vector2.UP)
#		print("execute rule init2 at" + str(chosenEdge))

func rule_extend_1(graph: Node2D):
	var matchEdge: Array = []
	for edge in graph.get_edges():
		#check if there is 2 vertex connected
		if edge.type == TYPE_EDGE.PATH:
			matchEdge.append(edge)

	if matchEdge.size() > 0:
		var chosenEdge: Node2D = matchEdge[randi() % matchEdge.size()]
		var vertex1: Node2D = chosenEdge.from
		var vertex2: Node2D = chosenEdge.to
		var vertex3: Node2D = graph.add_vertex()
		
		vertex3.add_to_group("placeVertices" + graph.name)
		
		var direction: Vector2 = vertex1.position.direction_to(vertex2.position)
		var targetPos: Vector2 = vertex1.position + (direction * cellSize)
		
		#if that position has a vertex
		if graph.is_pos_has_placed(targetPos, vertex3):
			graph.slide_vertices(targetPos, direction)
		graph.change_vertex_pos(vertex3, targetPos)
		
		chosenEdge.init_object(vertex1, vertex3, TYPE_EDGE.PATH, direction)
		graph.connect_vertex(vertex3, vertex2, TYPE_EDGE.PATH, direction)
#		print("execute rule Extend1 at" + str(chosenEdge))

func rule_extend_2(graph: Node2D):
	var matchEdge: Array = []
	for edge in graph.get_edges():
		if edge.type == TYPE_EDGE.PATH and graph.get_edges_of(edge.from).size() < 4 and graph.get_edges_of(edge.to).size() < 4:
			var allowVertex: Array = [TYPE_VERTEX.TASK, TYPE_VERTEX.START, TYPE_VERTEX.GOAL]
			if allowVertex.has(edge.from.type) and allowVertex.has(edge.to.type) and ((edge.from.connections[Vector2.LEFT] == null and edge.to.connections[Vector2.LEFT] == null) or (edge.from.connections[Vector2.RIGHT] == null and edge.to.connections[Vector2.RIGHT] == null) or (edge.from.connections[Vector2.UP] == null and edge.to.connections[Vector2.UP] == null) or (edge.from.connections[Vector2.DOWN] == null and edge.to.connections[Vector2.DOWN] == null)):
				matchEdge.append(edge)

	if matchEdge.size() > 0:
		var chosenEdge: Node2D = matchEdge[randi() % matchEdge.size()]
		var vertex1: Node2D = chosenEdge.from
		var vertex2: Node2D = chosenEdge.to
		var vertex3: Node2D = graph.add_vertex()
		var vertex4: Node2D = graph.add_vertex()
		
		vertex3.add_to_group("placeVertices" + graph.name)
		vertex4.add_to_group("placeVertices" + graph.name)
		
		var direction: Vector2 = vertex1.position.direction_to(vertex2.position)
		var directionOptions: Array = []
		for option in DIRECTIONS:
			if vertex1.connections[option] == null and vertex2.connections[option] == null:
				directionOptions.append(option)
		var chosenOption: Vector2 = directionOptions[randi() % directionOptions.size()]
		var mirrorOption: Vector2 = Vector2(chosenOption.x * -1, chosenOption.y) if chosenOption.x != 0 else Vector2(chosenOption.x, chosenOption.y * -1)
		var targetPos: Vector2 = vertex2.position + (chosenOption * cellSize)
		var targetPos2: Vector2 = vertex1.position + (chosenOption * cellSize)
		#if that position has a vertex
		if graph.is_pos_has_placed(targetPos, vertex3) or graph.is_pos_crossed_line(targetPos, chosenOption):
			graph.slide_vertices(targetPos, chosenOption)
		graph.change_vertex_pos(vertex3, targetPos)
		if graph.is_pos_has_placed(targetPos2,vertex4) or graph.is_pos_crossed_line(targetPos2, chosenOption):
			graph.slide_vertices(targetPos2, chosenOption)
		graph.change_vertex_pos(vertex4, targetPos2)
		
		graph.connect_vertex(vertex1, vertex4, TYPE_EDGE.PATH, chosenOption)
		graph.connect_vertex(vertex4, vertex3, TYPE_EDGE.PATH, direction)
		graph.connect_vertex(vertex3, vertex2, TYPE_EDGE.PATH, mirrorOption)
#		print("execute rule Extend2 at" + str(chosenEdge))

func rule_extend_3(graph: Node2D):
	var matchEdge: Array = []
	for edge in graph.get_edges():
		#check if there is 2 vertex connected
		if edge.type == TYPE_EDGE.PATH and graph.get_edges_of(edge.from).size() < 4 and graph.get_edges_of(edge.to).size() < 4:
			#check if there is 2 vertex have same direction null
			var allowVertex: Array = [TYPE_VERTEX.TASK, TYPE_VERTEX.START, TYPE_VERTEX.GOAL]
			if allowVertex.has(edge.from.type) and allowVertex.has(edge.to.type) and ((edge.from.connections[Vector2.LEFT] == null and edge.to.connections[Vector2.LEFT] == null) or (edge.from.connections[Vector2.RIGHT] == null and edge.to.connections[Vector2.RIGHT] == null) or (edge.from.connections[Vector2.UP] == null and edge.to.connections[Vector2.UP] == null) or (edge.from.connections[Vector2.DOWN] == null and edge.to.connections[Vector2.DOWN] == null)):
				matchEdge.append(edge)

	if matchEdge.size() > 0:
		var chosenEdge: Node2D = matchEdge[randi() % matchEdge.size()]
		var vertex1: Node2D = chosenEdge.from
		var vertex2: Node2D = chosenEdge.to
		var vertex3: Node2D = graph.add_vertex()
		var vertex4: Node2D = graph.add_vertex()
		
		vertex3.add_to_group("placeVertices" + graph.name)
		vertex4.add_to_group("placeVertices" + graph.name)
		
		var direction: Vector2 = vertex1.position.direction_to(vertex2.position)
		var mirrorDirection: Vector2 = Vector2(direction.x * -1, direction.y) if direction.x != 0 else Vector2(direction.x, direction.y * -1)
		var directionOptions: Array = []
		for option in DIRECTIONS:
			if vertex1.connections[option] == null and vertex2.connections[option] == null:
				directionOptions.append(option)
		var chosenOption: Vector2 = directionOptions[randi() % directionOptions.size()]
		var mirrorOption: Vector2 = Vector2(chosenOption.x * -1, chosenOption.y) if chosenOption.x != 0 else Vector2(chosenOption.x, chosenOption.y * -1)
		var targetPos: Vector2 = vertex2.position + (chosenOption * cellSize)
		var targetPos2: Vector2 = vertex1.position + (chosenOption * cellSize)
		#if that position has a vertex
		if graph.is_pos_has_placed(targetPos, vertex3) or graph.is_pos_crossed_line(targetPos, chosenOption):
			graph.slide_vertices(targetPos, chosenOption)
		graph.change_vertex_pos(vertex3, targetPos)
		if graph.is_pos_has_placed(targetPos2, vertex4) or graph.is_pos_crossed_line(targetPos2, chosenOption):
			graph.slide_vertices(targetPos2, chosenOption)
		graph.change_vertex_pos(vertex4, targetPos2)
		
		graph.connect_vertex(vertex2, vertex3, TYPE_EDGE.PATH, chosenOption)
		graph.connect_vertex(vertex3, vertex4, TYPE_EDGE.PATH, mirrorDirection)
		graph.connect_vertex(vertex4, vertex1, TYPE_EDGE.PATH, mirrorOption)
#		print("execute rule Extend2 at" + str(chosenEdge))

func rule_secret(graph: Node2D):
	var matchEdge: Array = []
	for edge in graph.get_edges():
		#check if there is init vertex
		var allowVertex: Array = [TYPE_VERTEX.TASK, TYPE_VERTEX.START, TYPE_VERTEX.GOAL]
		if ((allowVertex.has(edge.from.type) and graph.get_edges_of(edge.from).size() < 4) or (allowVertex.has(edge.to.type) and graph.get_edges_of(edge.to).size() < 4 )) and edge.type == TYPE_EDGE.PATH and (edge.from.connections.values().has(null) or edge.to.connections.values().has(null)):
			matchEdge.append(edge)
	
	if matchEdge.size() > 0:
		var chosenEdge = matchEdge[randi() % matchEdge.size()]
		
		var arrayVertex: Array = []
		var allowVertex: Array = [TYPE_VERTEX.TASK, TYPE_VERTEX.START, TYPE_VERTEX.GOAL]
		if allowVertex.has(chosenEdge.from.type) and graph.get_edges_of(chosenEdge.from).size() < 4 and chosenEdge.from.connections.values().has(null):
			arrayVertex.append(chosenEdge.from)
		if allowVertex.has(chosenEdge.to.type) and graph.get_edges_of(chosenEdge.to).size() < 4 and chosenEdge.to.connections.values().has(null):
			arrayVertex.append(chosenEdge.to)
		
		var vertex1: Node2D = arrayVertex[randi() % arrayVertex.size()]
		var vertex2: Node2D = graph.add_vertex("",TYPE_VERTEX.SECRET)
		
		var directions: Array = []
		for direction in vertex1.connections.keys():
			if vertex1.connections[direction] == null:
				directions.append(direction)
		var direction: Vector2 = directions[randi() % directions.size()]
		var targetPos: Vector2 = vertex1.position + (direction * cellSize)
		
		#if that position has a vertex
		if graph.is_pos_has_placed(targetPos, vertex2) or graph.is_pos_crossed_line(targetPos, direction):
			graph.slide_vertices(targetPos, direction)
		graph.change_vertex_pos(vertex2, targetPos)
		
		graph.connect_vertex(vertex1, vertex2, TYPE_EDGE.PATH, direction)
#		print("execute rule Secret at" + str(chosenEdge) + "detail : " + vertex1.name)

func rule_obstacle(graph: Node2D):
	var matchEdge: Array = []
	for edge in graph.get_edges():
		#check if there is 2 vertex connected
		if edge.to != null:
			matchEdge.append(edge)
	
	if matchEdge.size() > 0:
		var chosenEdge: Node2D = matchEdge[randi() % matchEdge.size()]
		var vertex1: Node2D = chosenEdge.from
		var vertex2: Node2D = chosenEdge.to
		var vertex3: Node2D = graph.add_vertex("", TYPE_VERTEX.OBSTACLE)
		
		var direction: Vector2 = vertex1.position.direction_to(vertex2.position)
		var targetPos: Vector2 = vertex1.position + (direction * cellSize)
		
		#if that position has a vertex
		if graph.is_pos_has_placed(targetPos, vertex3):
			graph.slide_vertices(targetPos, direction)
		graph.change_vertex_pos(vertex3, targetPos)
		
		chosenEdge.init_object(vertex1, vertex3, TYPE_EDGE.PATH, direction)
		graph.connect_vertex(vertex3, vertex2, TYPE_EDGE.PATH, direction)
#		print("execute rule Obstacle at" + str(chosenEdge))

func rule_reward(graph: Node2D):
	var matchEdge: Array = []
	for edge in graph.get_edges():
		#check if there is 2 vertex connected
		if edge.to != null:
			matchEdge.append(edge)
	
	if matchEdge.size() > 0:
		var chosenEdge: Node2D = matchEdge[randi() % matchEdge.size()]
		var vertex1: Node2D = chosenEdge.from
		var vertex2: Node2D = chosenEdge.to
		var vertex3: Node2D = graph.add_vertex("", TYPE_VERTEX.OBSTACLE)
		var vertex4: Node2D = graph.add_vertex("", TYPE_VERTEX.REWARD)
		
		var direction: Vector2 = vertex1.position.direction_to(vertex2.position)
		var targetPos: Vector2 = vertex1.position + (direction * cellSize)
		var targetPos2: Vector2 = targetPos + (direction * cellSize)
		#if that position has a vertex
		if graph.is_pos_has_placed(targetPos, vertex3):
			graph.slide_vertices(targetPos, direction)
		graph.change_vertex_pos(vertex3, targetPos)
		if graph.is_pos_has_placed(targetPos2, vertex4):
			graph.slide_vertices(targetPos2, direction)
		graph.change_vertex_pos(vertex4, targetPos2)
		
		chosenEdge.init_object(vertex1, vertex3, TYPE_EDGE.PATH, direction)
		graph.connect_vertex(vertex3, vertex4, TYPE_EDGE.PATH, direction)
		graph.connect_vertex(vertex4, vertex2, TYPE_EDGE.PATH, direction)
#		print("execute rule Reward at" + str(chosenEdge))

func rule_knl_1(graph: Node2D):
	var matchEdge: Array = []
	for edge in graph.get_edges():
		#check if there is 2 place vertex connected
		if !edge.from.is_element() and !edge.to.is_element() and edge.type != TYPE_EDGE.KEY_LOCK:
			matchEdge.append(edge)
	
	if matchEdge.size() > 0:
		var chosenEdge: Node2D = matchEdge[randi() % matchEdge.size()]
		var vertex1: Node2D = chosenEdge.from
		var vertex2: Node2D = chosenEdge.to
		var vertex3: Node2D = graph.add_vertex("", TYPE_VERTEX.KEY)
		var vertex4: Node2D = graph.add_vertex("", TYPE_VERTEX.TASK)
		var vertex5: Node2D = graph.add_vertex("", TYPE_VERTEX.LOCK)
		
		vertex4.add_to_group("placeVertices" + graph.name)
		
		var direction: Vector2 = vertex1.position.direction_to(vertex2.position)
		var targetPos: Vector2 = vertex1.position + (direction * cellSize)
		var targetPos2: Vector2 = targetPos + (direction * cellSize)
		var targetPos3: Vector2 = targetPos2 + (direction * cellSize)
		#if that position has a vertex
		if graph.is_pos_has_placed(targetPos, vertex3):
			graph.slide_vertices(targetPos, direction)
		graph.change_vertex_pos(vertex3, targetPos)
		if graph.is_pos_has_placed(targetPos2, vertex4):
			graph.slide_vertices(targetPos2, direction)
		graph.change_vertex_pos(vertex4, targetPos2)
		if graph.is_pos_has_placed(targetPos3, vertex5):
			graph.slide_vertices(targetPos3, direction)
		graph.change_vertex_pos(vertex5, targetPos3)
		
		chosenEdge.init_object(vertex1, vertex3, TYPE_EDGE.PATH, direction)
		graph.connect_vertex(vertex3, vertex4, TYPE_EDGE.PATH, direction)
		graph.connect_vertex(vertex4, vertex5, TYPE_EDGE.PATH, direction)
		graph.connect_vertex(vertex5, vertex2, TYPE_EDGE.PATH, direction)
		graph.connect_vertex(vertex3, vertex5, TYPE_EDGE.KEY_LOCK)
#		print("execute rule KL1 at" + str(edge))

func rule_knl_2(graph: Node2D):
	var matchEdge: Array = []
	for edge in graph.get_edges():
		#check if there is 2 vertex connected
		if edge.to != null and graph.get_edges_of(edge.from).size() < 4 and graph.get_edges_of(edge.to).size() < 4 and edge.type != TYPE_EDGE.KEY_LOCK:
			#check if there is 2 vertex have same direction null
			var allowVertex: Array = [TYPE_VERTEX.TASK, TYPE_VERTEX.START, TYPE_VERTEX.GOAL]
			if allowVertex.has(edge.from.type) and allowVertex.has(edge.to.type) and ((edge.from.connections[Vector2.LEFT] == null and edge.to.connections[Vector2.LEFT] == null) or (edge.from.connections[Vector2.RIGHT] == null and edge.to.connections[Vector2.RIGHT] == null) or (edge.from.connections[Vector2.UP] == null and edge.to.connections[Vector2.UP] == null) or (edge.from.connections[Vector2.DOWN] == null and edge.to.connections[Vector2.DOWN] == null)):
				matchEdge.append(edge)
	
	if matchEdge.size() > 0:
		var chosenEdge: Node2D = matchEdge[randi() % matchEdge.size()]
		var vertex1: Node2D = chosenEdge.from
		var vertex2: Node2D = chosenEdge.to
		var vertex3: Node2D = graph.add_vertex("", TYPE_VERTEX.TASK)
		var vertex4: Node2D = graph.add_vertex("", TYPE_VERTEX.LOCK)
		var vertex5: Node2D = graph.add_vertex("", TYPE_VERTEX.KEY)
		var vertex6: Node2D = graph.add_vertex("", TYPE_VERTEX.TASK)
		
		vertex3.add_to_group("placeVertices" + graph.name)
		vertex6.add_to_group("placeVertices" + graph.name)
		
		var direction: Vector2 = vertex1.position.direction_to(vertex2.position)
		var targetPos: Vector2 = vertex1.position + (direction * cellSize)
		var targetPos2: Vector2 = targetPos + (direction * cellSize)
		#if that position has a vertex
		if graph.is_pos_has_placed(targetPos, vertex3):
			graph.slide_vertices(targetPos, direction)
		graph.change_vertex_pos(vertex3, targetPos)
		if graph.is_pos_has_placed(targetPos2, vertex4):
			graph.slide_vertices(targetPos2, direction)
		graph.change_vertex_pos(vertex4, targetPos2)
		
		chosenEdge.init_object(vertex1, vertex3, TYPE_EDGE.PATH, direction)
		graph.connect_vertex(vertex3, vertex4, TYPE_EDGE.PATH, direction)
		graph.connect_vertex(vertex4, vertex2, TYPE_EDGE.PATH, direction)
		
		var directionOptions: Array = []
		for option in DIRECTIONS:
			if vertex1.connections[option] == null and vertex3.connections[option] == null:
				directionOptions.append(option)
		var chosenOption: Vector2 = directionOptions[randi() % directionOptions.size()]
		var mirrorOption: Vector2 = Vector2(chosenOption.x * -1, chosenOption.y) if chosenOption.x != 0 else Vector2(chosenOption.x, chosenOption.y * -1)
		var targetPos3: Vector2 = vertex1.position + (chosenOption * cellSize)
		var targetPos4: Vector2 = vertex3.position + (chosenOption * cellSize)
		#if that position has a vertex
		if graph.is_pos_has_placed(targetPos3, vertex6) or graph.is_pos_crossed_line(targetPos3, chosenOption):
			graph.slide_vertices(targetPos3, chosenOption)
		graph.change_vertex_pos(vertex6, targetPos3)
		if graph.is_pos_has_placed(targetPos4, vertex5) or graph.is_pos_crossed_line(targetPos4, chosenOption):
			graph.slide_vertices(targetPos4, chosenOption)
		graph.change_vertex_pos(vertex5, targetPos4)
		
		graph.connect_vertex(vertex1, vertex6, TYPE_EDGE.PATH, chosenOption)
		graph.connect_vertex(vertex5, vertex3, TYPE_EDGE.PATH, mirrorOption)
		graph.connect_vertex(vertex6, vertex5, TYPE_EDGE.PATH, direction)
		graph.connect_vertex(vertex5, vertex4, TYPE_EDGE.KEY_LOCK)
#		print("execute rule KL2 at" + str(chosenEdge))

func rule_knl_3(graph: Node2D):
	var matchEdge: Array = []
	for edge in graph.get_edges():
		if edge.to != null and graph.get_edges_of(edge.from).size() < 4 and graph.get_edges_of(edge.to).size() < 4 and edge.type != TYPE_EDGE.KEY_LOCK:
			var allowVertex: Array = [TYPE_VERTEX.TASK, TYPE_VERTEX.START, TYPE_VERTEX.GOAL]
			if allowVertex.has(edge.from.type) and allowVertex.has(edge.to.type) and ((edge.from.connections[Vector2.LEFT] == null and edge.to.connections[Vector2.LEFT] == null) or (edge.from.connections[Vector2.RIGHT] == null and edge.to.connections[Vector2.RIGHT] == null) or (edge.from.connections[Vector2.UP] == null and edge.to.connections[Vector2.UP] == null) or (edge.from.connections[Vector2.DOWN] == null and edge.to.connections[Vector2.DOWN] == null)):
				matchEdge.append(edge)
	
	if matchEdge.size() > 0:
		var chosenEdge: Node2D = matchEdge[randi() % matchEdge.size()]
		var vertex1: Node2D = chosenEdge.from
		var vertex2: Node2D = chosenEdge.to
		var vertex3: Node2D = graph.add_vertex("", TYPE_VERTEX.TASK)
		var vertex4: Node2D = graph.add_vertex("", TYPE_VERTEX.LOCK)
		var vertex5: Node2D = graph.add_vertex("", TYPE_VERTEX.TASK)
		var vertex6: Node2D = graph.add_vertex("", TYPE_VERTEX.KEY)
		
		vertex3.add_to_group("placeVertices" + graph.name)
		vertex5.add_to_group("placeVertices" + graph.name)
		
		var direction: Vector2 = vertex1.position.direction_to(vertex2.position)
		var mirrorDirection: Vector2 = Vector2(direction.x * -1, direction.y) if direction.x != 0 else Vector2(direction.x, direction.y * -1)
		var targetPos: Vector2 = vertex1.position + (direction * cellSize)
		var targetPos2: Vector2 = targetPos + (direction * cellSize)
		#if that position has a vertex
		if graph.is_pos_has_placed(targetPos, vertex3):
			graph.slide_vertices(targetPos, direction)
		graph.change_vertex_pos(vertex3, targetPos)
		if graph.is_pos_has_placed(targetPos2, vertex4):
			graph.slide_vertices(targetPos2, direction)
		graph.change_vertex_pos(vertex4, targetPos2)
		
		chosenEdge.init_object(vertex1, vertex3, TYPE_EDGE.PATH, direction)
		graph.connect_vertex(vertex3, vertex4, TYPE_EDGE.PATH, direction)
		graph.connect_vertex(vertex4, vertex2, TYPE_EDGE.PATH, direction)
		
		var directionOptions: Array = []
		for option in DIRECTIONS:
			if vertex1.connections[option] == null and vertex3.connections[option] == null:
				directionOptions.append(option)
		var chosenOption: Vector2 = directionOptions[randi() % directionOptions.size()]
		var mirrorOption: Vector2 = Vector2(chosenOption.x * -1, chosenOption.y) if chosenOption.x != 0 else Vector2(chosenOption.x, chosenOption.y * -1)
		var targetPos3: Vector2 = vertex1.position + (chosenOption * cellSize)
		var targetPos4: Vector2 = vertex3.position + (chosenOption * cellSize)
		#if that position has a vertex
		if graph.is_pos_has_placed(targetPos3, vertex6) or graph.is_pos_crossed_line(targetPos3, chosenOption):
			graph.slide_vertices(targetPos3, chosenOption)
		graph.change_vertex_pos(vertex6, targetPos3)
		if graph.is_pos_has_placed(targetPos4, vertex5) or graph.is_pos_crossed_line(targetPos4, chosenOption):
			graph.slide_vertices(targetPos4, chosenOption)
		graph.change_vertex_pos(vertex5, targetPos4)
		
		graph.connect_vertex(vertex6, vertex1, TYPE_EDGE.PATH, mirrorOption)
		graph.connect_vertex(vertex3, vertex5, TYPE_EDGE.PATH, chosenOption)
		graph.connect_vertex(vertex5, vertex6, TYPE_EDGE.PATH, mirrorDirection)
		graph.connect_vertex(vertex6, vertex4, TYPE_EDGE.KEY_LOCK)
#		print("execute rule KL3 at" + str(chosenEdge))

func rule_knl_4(graph: Node2D):
	var matchEdge: Array = []
	for edge in graph.get_edges():
		#check if there is 2 vertex connected and the secon vertex type is goal
		if !edge.from.is_element() and edge.to.type == TYPE_VERTEX.GOAL and edge.type != TYPE_EDGE.KEY_LOCK:
			matchEdge.append(edge)
	
	if matchEdge.size() > 0:
		var chosenEdge: Node2D = matchEdge[randi() % matchEdge.size()]
		var vertex1: Node2D = chosenEdge.from
		var vertex2: Node2D = chosenEdge.to
		var vertex3: Node2D = graph.add_vertex("", TYPE_VERTEX.KEY)
		var vertex4: Node2D = graph.add_vertex("", TYPE_VERTEX.TASK)
		var vertex5: Node2D = graph.add_vertex("", TYPE_VERTEX.LOCK)
		
		vertex4.add_to_group("placeVertices" + graph.name)
		
		var direction: Vector2 = vertex1.position.direction_to(vertex2.position)
		var targetPos: Vector2 = vertex1.position + (direction * cellSize)
		var targetPos2: Vector2 = targetPos + (direction * cellSize)
		var targetPos3: Vector2 = targetPos2 + (direction * cellSize)
		#if that position has a vertex
		if graph.is_pos_has_placed(targetPos, vertex3):
			graph.slide_vertices(targetPos, direction)
		graph.change_vertex_pos(vertex3, targetPos)
		if graph.is_pos_has_placed(targetPos2, vertex4):
			graph.slide_vertices(targetPos2, direction)
		graph.change_vertex_pos(vertex4, targetPos2)
		if graph.is_pos_has_placed(targetPos3, vertex5):
			graph.slide_vertices(targetPos3, direction)
		graph.change_vertex_pos(vertex5, targetPos3)
		
		chosenEdge.init_object(vertex1, vertex3, TYPE_EDGE.PATH, direction)
		graph.connect_vertex(vertex3, vertex4, TYPE_EDGE.PATH, direction)
		graph.connect_vertex(vertex4, vertex5, TYPE_EDGE.PATH, direction)
		graph.connect_vertex(vertex5, vertex2, TYPE_EDGE.PATH, direction)
		graph.connect_vertex(vertex3, vertex5, TYPE_EDGE.KEY_LOCK)
#		print("execute rule KL4 at" + str(chosenEdge))

func random_init(graph: Node2D):
	var chosenrule = randi() % 2 + 1
	if chosenrule == 1:
		rule_init_1(graph)
	else:
		rule_init_2(graph)

func random_extend(graph: Node2D):
	var chosenrule = randi() % 3 + 1
	if chosenrule == 1:
		rule_extend_1(graph)
	elif chosenrule == 2:
		rule_extend_2(graph)
	else:
		rule_extend_3(graph)

func random_knl(graph: Node2D):
	var chosenrule = randi() % 4 + 1
	match chosenrule:
		1: rule_knl_1(graph)
		2: rule_knl_2(graph)
		3: rule_knl_3(graph)
		4: rule_knl_4(graph)
