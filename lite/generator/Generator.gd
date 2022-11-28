extends Node2D

onready var gui = $"%GUI"
onready var graphs = $"%Graphs"

const Graph = preload("res://lite/graph/Graph.tscn")
const Vertex = preload("res://lite/vertex/Vertex.tscn")
const Edge = preload("res://lite/edge/Edge.tscn")

var targetGraph: Node2D = null
var indexGraph: int = 0
var indexVertex: int = 0
var recipe: Array = []
const DEFAULT_RECIPE: Array = [
	"randomInit",
	"randomExtend", "randomExtend", "randomExtend",
	"secret",
	"obstacle", "obstacle",
	"reward", "reward", "reward",
	"randomKeyLock", "randomKeyLock", "randomKeyLock"
]
var gridSize: Vector2 = Vector2(20,20)
var cellSize: Vector2 = Vector2(256,256)

const DIRECTIONS = [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]

# Called when the node enters the scene tree for the first time.
func _ready():
	recipe = DEFAULT_RECIPE
	for rule in recipe:
		$"%RichTextRecipe".add_text(rule)
		$"%RichTextRecipe".newline()
	randomize()

func _input(event):
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == BUTTON_RIGHT:
		var mouse = get_viewport().get_mouse_position()
		if !event.control:
			$"%WindowDialogGenerator".popup(Rect2(mouse.x, mouse.y, $"%WindowDialogGenerator".rect_size.x, $"%WindowDialogGenerator".rect_size.y))
		else:
			$"%WindowDialogGraph".popup(Rect2(mouse.x, mouse.y, $"%WindowDialogGraph".rect_size.x, $"%WindowDialogGraph".rect_size.y))

#disable for performance
func _process(delta):
	if targetGraph == null:
		$"%ButtonExecuteSingleRule".disabled = true
		$"%ButtonExecuteRecipe".disabled = true
		$"%ButtonTransform".disabled = true
	else:
		$"%ButtonExecuteSingleRule".disabled = false
		$"%ButtonExecuteRecipe".disabled = false
		$"%ButtonTransform".disabled = false

func _create_graph():
	#make graph
	var graph = Graph.instance()
	graph.init_object("graph"+str(indexGraph), indexGraph)
	var posx = indexGraph * gridSize.x * cellSize.x
	graph.gridSize = gridSize
	graph.cellSize = cellSize
	graph.position = Vector2(posx, 0)
	graph.update()
	graphs.add_child(graph)
	
	#initiate vertex
	var vertexinit = graph.add_vertex("",TYPE_VERTEX.INIT)
	graph.connect_vertex(vertexinit, null)
	
	#add to option
	$"%OptionTargetGraph".add_item(graph.name, indexGraph)
	$"%OptionTargetGraph".select(indexGraph)
	$"%OptionTargetGraph2".add_item(graph.name, indexGraph)
	$"%OptionTargetGraph2".select(indexGraph)
	targetGraph = graph
	indexGraph += 1

# collection of rules ==========================================================

func _rule_init_1(graph: Node):
	var matchEdge: Array = []
	for edge in graph.get_edges():
		#check if there is init vertex
		var from = graph.get_vertex(edge.from)
		if from.type == TYPE_VERTEX.INIT and edge.to == null:
			matchEdge.append(edge)

	if matchEdge.size() > 0:
		var chosenEdge: Node2D = matchEdge[randi() % matchEdge.size()]
		var vertex1: Node2D = graph.get_vertex(chosenEdge.from)
		var vertex2: Node2D = graph.add_vertex()
		var vertex3: Node2D = graph.add_vertex("",TYPE_VERTEX.GOAL)
		var vertex4: Node2D = graph.add_vertex()
		
		vertex1.type = TYPE_VERTEX.START
		graph.change_vertex_pos(vertex2, vertex1.position + (Vector2.RIGHT * cellSize))
		graph.change_vertex_pos(vertex3, vertex2.position + (Vector2.DOWN * cellSize))
		graph.change_vertex_pos(vertex4, vertex1.position + (Vector2.DOWN * cellSize))
		
		chosenEdge.init_object(vertex1, vertex2, TYPE_EDGE.PATH, Vector2.RIGHT)
		graph.connect_vertex(vertex2, vertex3, TYPE_EDGE.PATH, Vector2.DOWN)
		graph.connect_vertex(vertex3, vertex4, TYPE_EDGE.PATH, Vector2.LEFT)
		graph.connect_vertex(vertex4, vertex1, TYPE_EDGE.PATH, Vector2.UP)
#		print("execute rule init1 at" + str(chosenEdge))

func _rule_init_2(graph: Node):
	var matchEdge: Array = []
	for edge in graph.get_edges():
		#check if there is init vertex
		var from = graph.get_vertex(edge.from)
		if from.type == TYPE_VERTEX.INIT and edge.to == null:
			matchEdge.append(edge)

	if matchEdge.size() > 0:
		var chosenEdge = matchEdge[randi() % matchEdge.size()]
		var vertex1: Node2D = graph.get_vertex(chosenEdge.from)
		var vertex2: Node2D = graph.add_vertex()
		var vertex3: Node2D = graph.add_vertex()
		var vertex4: Node2D = graph.add_vertex()
		var vertex5: Node2D = graph.add_vertex("",TYPE_VERTEX.GOAL)
		var vertex6: Node2D = graph.add_vertex()
		
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

func _rule_extend_1(graph: Node):
	var matchEdge: Array = []
	for edge in graph.get_edges():
		#check if there is 2 vertex connected
		if edge.type == TYPE_EDGE.PATH:
			matchEdge.append(edge)

	if matchEdge.size() > 0:
		var chosenEdge: Node2D = matchEdge[randi() % matchEdge.size()]
		var vertex1: Node2D = graph.get_vertex(chosenEdge.from)
		var vertex2: Node2D = graph.get_vertex(chosenEdge.to)
		var vertex3: Node2D = graph.add_vertex()
		
		var direction: Vector2 = (vertex2.position - vertex1.position).normalized()
		var targetPos: Vector2 = vertex1.position + (direction * cellSize)
		
		#if that position has a vertex
		if graph.is_pos_has_placed(targetPos):
			graph.slide_vertices(targetPos, direction)
		graph.change_vertex_pos(vertex3, targetPos)
		
		chosenEdge.init_object(vertex1, vertex3, TYPE_EDGE.PATH, direction)
		graph.connect_vertex(vertex3, vertex2, TYPE_EDGE.PATH, direction)
#		print("execute rule Extend1 at" + str(chosenEdge))

func _rule_extend_2(graph: Node):
	var matchEdge: Array = []
	for edge in graph.get_edges():
		if edge.type == TYPE_EDGE.PATH and graph.get_edges_of(edge.from).size() < 4 and graph.get_edges_of(edge.to).size() < 4:
			var from = graph.get_vertex(edge.from)
			var to = graph.get_vertex(edge.to)
			if (from.connections[Vector2.LEFT] == null and to.connections[Vector2.LEFT] == null) or (from.connections[Vector2.RIGHT] == null and to.connections[Vector2.RIGHT] == null) or (from.connections[Vector2.UP] == null and to.connections[Vector2.UP] == null) or (from.connections[Vector2.DOWN] == null and to.connections[Vector2.DOWN] == null):
				matchEdge.append(edge)

	if matchEdge.size() > 0:
		var chosenEdge: Node2D = matchEdge[randi() % matchEdge.size()]
		var vertex1: Node2D = graph.get_vertex(chosenEdge.from)
		var vertex2: Node2D = graph.get_vertex(chosenEdge.to)
		var vertex3: Node2D = graph.add_vertex()
		var vertex4: Node2D = graph.add_vertex()
		
		var direction: Vector2 = (vertex2.position - vertex1.position).normalized()
		var directionOptions: Array = []
		for option in DIRECTIONS:
			if vertex1.connections[option] == null and vertex2.connections[option] == null:
				directionOptions.append(option)
		var chosenOption: Vector2 = directionOptions[randi() % directionOptions.size()]
		var mirrorOption: Vector2 = Vector2(chosenOption.x * -1, chosenOption.y) if chosenOption.x != 0 else Vector2(chosenOption.x, chosenOption.y * -1)
		var targetPos: Vector2 = vertex2.position + (chosenOption * cellSize)
		var targetPos2: Vector2 = vertex1.position + (chosenOption * cellSize)
		#if that position has a vertex
		if graph.is_pos_has_placed(targetPos) and graph.is_pos_crossed_line(targetPos):
			graph.slide_vertices(targetPos, chosenOption)
		if graph.is_pos_has_placed(targetPos2) and graph.is_pos_crossed_line(targetPos2):
			graph.slide_vertices(targetPos2, chosenOption)
		
		graph.change_vertex_pos(vertex3, targetPos)
		graph.change_vertex_pos(vertex4, targetPos2)
		
		graph.connect_vertex(vertex1, vertex4, TYPE_EDGE.PATH, chosenOption)
		graph.connect_vertex(vertex4, vertex3, TYPE_EDGE.PATH, direction)
		graph.connect_vertex(vertex3, vertex2, TYPE_EDGE.PATH, mirrorOption)
#		print("execute rule Extend2 at" + str(chosenEdge))

func _rule_extend_3(graph: Node):
	var matchEdge: Array = []
	for edge in graph.get_edges():
		#check if there is 2 vertex connected
		if edge.type == TYPE_EDGE.PATH and graph.get_edges_of(edge.from).size() < 4 and graph.get_edges_of(edge.to).size() < 4:
			#check if there is 2 vertex have same direction null
			var from = graph.get_vertex(edge.from)
			var to = graph.get_vertex(edge.to)
			if (from.connections[Vector2.LEFT] == null and to.connections[Vector2.LEFT] == null) or (from.connections[Vector2.RIGHT] == null and to.connections[Vector2.RIGHT] == null) or (from.connections[Vector2.UP] == null and to.connections[Vector2.UP] == null) or (from.connections[Vector2.DOWN] == null and to.connections[Vector2.DOWN] == null):
				matchEdge.append(edge)

	if matchEdge.size() > 0:
		var chosenEdge: Node2D = matchEdge[randi() % matchEdge.size()]
		var vertex1: Node2D = graph.get_vertex(chosenEdge.from)
		var vertex2: Node2D = graph.get_vertex(chosenEdge.to)
		var vertex3: Node2D = graph.add_vertex()
		var vertex4: Node2D = graph.add_vertex()
		
		var direction: Vector2 = (vertex2.position - vertex1.position).normalized()
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
		if graph.is_pos_has_placed(targetPos) and graph.is_pos_crossed_line(targetPos):
			graph.slide_vertices(targetPos, chosenOption)
		if graph.is_pos_has_placed(targetPos2) and graph.is_pos_crossed_line(targetPos2):
			graph.slide_vertices(targetPos2, chosenOption)
		
		graph.change_vertex_pos(vertex3, targetPos)
		graph.change_vertex_pos(vertex4, targetPos2)
		
		graph.connect_vertex(vertex2, vertex3, TYPE_EDGE.PATH, chosenOption)
		graph.connect_vertex(vertex3, vertex4, TYPE_EDGE.PATH, mirrorDirection)
		graph.connect_vertex(vertex4, vertex1, TYPE_EDGE.PATH, mirrorOption)
#		print("execute rule Extend2 at" + str(chosenEdge))

func _rule_secret(graph: Node):
	var matchEdge: Array = []
	for edge in graph.get_edges():
		#check if there is init vertex
		var from = graph.get_vertex(edge.from)
		var to = graph.get_vertex(edge.to)
		if ((from.type == TYPE_VERTEX.TASK and graph.get_edges_of(from).size() < 4) or (to.type == TYPE_VERTEX.TASK and graph.get_edges_of(to).size() < 4 )) and edge.type == TYPE_EDGE.PATH and from.connections.values().has(null) and to.connections.values().has(null):
			matchEdge.append(edge)
	
	if matchEdge.size() > 0:
		var chosenEdge = matchEdge[randi() % matchEdge.size()]
		var from = graph.get_vertex(chosenEdge.from)
		var to = graph.get_vertex(chosenEdge.to)
		
		var arrayVertex: Array = []
		if from.type == TYPE_VERTEX.TASK and graph.get_edges_of(from).size() < 4 and from.connections.values().has(null):
			arrayVertex.append(from)
		if to.type == TYPE_VERTEX.TASK and graph.get_edges_of(to).size() < 4 and to.connections.values().has(null):
			arrayVertex.append(to)
		
		var vertex1: Node2D = arrayVertex[randi() % arrayVertex.size()]
		var vertex2: Node2D = graph.add_vertex("",TYPE_VERTEX.SECRET)
		
		var directions: Array = []
		for direction in vertex1.connections.keys():
			if vertex1.connections[direction] == null:
				directions.append(direction)
		var direction: Vector2 = directions[randi() % directions.size()]
		var targetPos: Vector2 = vertex1.position + (direction * cellSize)
		
		#if that position has a vertex
		if graph.is_pos_has_placed(targetPos) and graph.is_pos_crossed_line(targetPos):
			graph.slide_vertices(targetPos, direction)
		graph.change_vertex_pos(vertex2, targetPos)
		
		graph.connect_vertex(vertex1, vertex2, TYPE_EDGE.PATH, direction)
#		print("execute rule Secret at" + str(chosenEdge) + "detail : " + vertex1.name)

func _rule_obstacle(graph: Node):
	var matchEdge: Array = []
	for edge in graph.get_edges():
		#check if there is 2 vertex connected
		if edge.to != null:
			matchEdge.append(edge)
	
	if matchEdge.size() > 0:
		var chosenEdge: Node2D = matchEdge[randi() % matchEdge.size()]
		var vertex1: Node2D = graph.get_vertex(chosenEdge.from)
		var vertex2: Node2D = graph.get_vertex(chosenEdge.to)
		var vertex3: Node2D = graph.add_vertex("", TYPE_VERTEX.OBSTACLE)
		
		var direction: Vector2 = (vertex2.position - vertex1.position).normalized()
		var targetPos: Vector2 = vertex1.position + (direction * cellSize)
		
		#if that position has a vertex
		if graph.is_pos_has_placed(targetPos):
			graph.slide_vertices(targetPos, direction)
		graph.change_vertex_pos(vertex3, targetPos)
		
		chosenEdge.init_object(vertex1, vertex3, TYPE_EDGE.PATH, direction)
		graph.connect_vertex(vertex3, vertex2, TYPE_EDGE.PATH, direction)
#		print("execute rule Obstacle at" + str(chosenEdge))

func _rule_reward(graph: Node):
	var matchEdge: Array = []
	for edge in graph.get_edges():
		#check if there is 2 vertex connected
		if edge.to != null:
			matchEdge.append(edge)
	
	if matchEdge.size() > 0:
		var chosenEdge: Node2D = matchEdge[randi() % matchEdge.size()]
		var vertex1: Node2D = graph.get_vertex(chosenEdge.from)
		var vertex2: Node2D = graph.get_vertex(chosenEdge.to)
		var vertex3: Node2D = graph.add_vertex("", TYPE_VERTEX.OBSTACLE)
		var vertex4: Node2D = graph.add_vertex("", TYPE_VERTEX.REWARD)
		
		var direction: Vector2 = (vertex2.position - vertex1.position).normalized()
		var targetPos: Vector2 = vertex1.position + (direction * cellSize)
		var targetPos2: Vector2 = targetPos + (direction * cellSize)
		#if that position has a vertex
		if graph.is_pos_has_placed(targetPos):
			graph.slide_vertices(targetPos, direction)
		if graph.is_pos_has_placed(targetPos2):
			graph.slide_vertices(targetPos2, direction)
		graph.change_vertex_pos(vertex3, targetPos)
		graph.change_vertex_pos(vertex4, targetPos2)
		
		chosenEdge.init_object(vertex1, vertex3, TYPE_EDGE.PATH, direction)
		graph.connect_vertex(vertex3, vertex4, TYPE_EDGE.PATH, direction)
		graph.connect_vertex(vertex4, vertex2, TYPE_EDGE.PATH, direction)
#		print("execute rule Reward at" + str(chosenEdge))

func _rule_knl_1(graph: Node):
	var matchEdge: Array = []
	for edge in graph.get_edges():
		#check if there is 2 place vertex connected
		var from = graph.get_vertex(edge.from)
		var to = graph.get_vertex(edge.to)
		if !from.is_element() and !to.is_element() and edge.type != TYPE_EDGE.KEY_LOCK:
			matchEdge.append(edge)
	
	if matchEdge.size() > 0:
		var chosenEdge: Node2D = matchEdge[randi() % matchEdge.size()]
		var vertex1: Node2D = graph.get_vertex(chosenEdge.from)
		var vertex2: Node2D = graph.get_vertex(chosenEdge.to)
		var vertex3: Node2D = graph.add_vertex("", TYPE_VERTEX.KEY)
		var vertex4: Node2D = graph.add_vertex("", TYPE_VERTEX.TASK)
		var vertex5: Node2D = graph.add_vertex("", TYPE_VERTEX.LOCK)
		
		var direction: Vector2 = (vertex2.position - vertex1.position).normalized()
		var targetPos: Vector2 = vertex1.position + (direction * cellSize)
		var targetPos2: Vector2 = targetPos + (direction * cellSize)
		var targetPos3: Vector2 = targetPos2 + (direction * cellSize)
		#if that position has a vertex
		if graph.is_pos_has_placed(targetPos):
			graph.slide_vertices(targetPos, direction)
		if graph.is_pos_has_placed(targetPos2):
			graph.slide_vertices(targetPos2, direction)
		if graph.is_pos_has_placed(targetPos3):
			graph.slide_vertices(targetPos3, direction)
		graph.change_vertex_pos(vertex3, targetPos)
		graph.change_vertex_pos(vertex4, targetPos2)
		graph.change_vertex_pos(vertex5, targetPos3)
		
		chosenEdge.init_object(vertex1, vertex3, TYPE_EDGE.PATH, direction)
		graph.connect_vertex(vertex3, vertex4, TYPE_EDGE.PATH, direction)
		graph.connect_vertex(vertex4, vertex5, TYPE_EDGE.PATH, direction)
		graph.connect_vertex(vertex5, vertex2, TYPE_EDGE.PATH, direction)
		graph.connect_vertex(vertex3, vertex5, TYPE_EDGE.KEY_LOCK)
#		print("execute rule KL1 at" + str(edge))

func _rule_knl_2(graph: Node):
	var matchEdge: Array = []
	for edge in graph.get_edges():
		#check if there is 2 vertex connected
		if edge.to != null and graph.get_edges_of(edge.from).size() < 4 and graph.get_edges_of(edge.to).size() < 4 and edge.type != TYPE_EDGE.KEY_LOCK:
			#check if there is 2 vertex have same direction null
			var from = graph.get_vertex(edge.from)
			var to = graph.get_vertex(edge.to)
			if (from.connections[Vector2.LEFT] == null and to.connections[Vector2.LEFT] == null) or (from.connections[Vector2.RIGHT] == null and to.connections[Vector2.RIGHT] == null) or (from.connections[Vector2.UP] == null and to.connections[Vector2.UP] == null) or (from.connections[Vector2.DOWN] == null and to.connections[Vector2.DOWN] == null):
				matchEdge.append(edge)
	
	if matchEdge.size() > 0:
		var chosenEdge: Node2D = matchEdge[randi() % matchEdge.size()]
		print("knl2")
		print(chosenEdge)
		var vertex1: Node2D = graph.get_vertex(chosenEdge.from)
		var vertex2: Node2D = graph.get_vertex(chosenEdge.to)
		var vertex3: Node2D = graph.add_vertex("", TYPE_VERTEX.TASK)
		var vertex4: Node2D = graph.add_vertex("", TYPE_VERTEX.LOCK)
		var vertex5: Node2D = graph.add_vertex("", TYPE_VERTEX.KEY)
		var vertex6: Node2D = graph.add_vertex("", TYPE_VERTEX.TASK)
		
		var direction: Vector2 = (vertex2.position - vertex1.position).normalized()
		var targetPos: Vector2 = vertex1.position + (direction * cellSize)
		var targetPos2: Vector2 = targetPos + (direction * cellSize)
		#if that position has a vertex
		if graph.is_pos_has_placed(targetPos):
			graph.slide_vertices(targetPos, direction)
		if graph.is_pos_has_placed(targetPos2):
			graph.slide_vertices(targetPos2, direction)
		graph.change_vertex_pos(vertex3, targetPos)
		graph.change_vertex_pos(vertex4, targetPos2)
		
		chosenEdge.init_object(vertex1, vertex3, TYPE_EDGE.PATH, direction)
		graph.connect_vertex(vertex3, vertex4, TYPE_EDGE.PATH, direction)
		graph.connect_vertex(vertex4, vertex2, TYPE_EDGE.PATH, direction)
		
		var directionOptions: Array = []
		for option in DIRECTIONS:
			if vertex1.connections[option] == null and vertex3.connections[option] == null:
				directionOptions.append(option)
		var chosenOption: Vector2 = directionOptions[randi() % directionOptions.size()]
		print(chosenOption)
		var mirrorOption: Vector2 = Vector2(chosenOption.x * -1, chosenOption.y) if chosenOption.x != 0 else Vector2(chosenOption.x, chosenOption.y * -1)
		var targetPos3: Vector2 = vertex1.position + (chosenOption * cellSize)
		var targetPos4: Vector2 = vertex3.position + (chosenOption * cellSize)
		#if that position has a vertex
		if graph.is_pos_has_placed(targetPos3) and graph.is_pos_crossed_line(targetPos3):
			graph.slide_vertices(targetPos3, chosenOption)
		if graph.is_pos_has_placed(targetPos4) and graph.is_pos_crossed_line(targetPos4):
			graph.slide_vertices(targetPos4, chosenOption)
		graph.change_vertex_pos(vertex6, targetPos3)
		graph.change_vertex_pos(vertex5, targetPos4)
		
		graph.connect_vertex(vertex1, vertex6, TYPE_EDGE.PATH, chosenOption)
		graph.connect_vertex(vertex5, vertex3, TYPE_EDGE.PATH, mirrorOption)
		graph.connect_vertex(vertex6, vertex5, TYPE_EDGE.PATH, direction)
		graph.connect_vertex(vertex5, vertex4, TYPE_EDGE.KEY_LOCK)
#		print("execute rule KL2 at" + str(chosenEdge))

func _rule_knl_3(graph: Node):
	var matchEdge: Array = []
	for edge in graph.get_edges():
		if edge.to != null and graph.get_edges_of(edge.from).size() < 4 and graph.get_edges_of(edge.to).size() < 4 and edge.type != TYPE_EDGE.KEY_LOCK:
			var from = graph.get_vertex(edge.from)
			var to = graph.get_vertex(edge.to)
			if (from.connections[Vector2.LEFT] == null and to.connections[Vector2.LEFT] == null) or (from.connections[Vector2.RIGHT] == null and to.connections[Vector2.RIGHT] == null) or (from.connections[Vector2.UP] == null and to.connections[Vector2.UP] == null) or (from.connections[Vector2.DOWN] == null and to.connections[Vector2.DOWN] == null):
				matchEdge.append(edge)
	
	if matchEdge.size() > 0:
		print("knl3")
		var chosenEdge: Node2D = matchEdge[randi() % matchEdge.size()]
		print(chosenEdge)
		var vertex1: Node2D = graph.get_vertex(chosenEdge.from)
		var vertex2: Node2D = graph.get_vertex(chosenEdge.to)
		var vertex3: Node2D = graph.add_vertex("", TYPE_VERTEX.TASK)
		var vertex4: Node2D = graph.add_vertex("", TYPE_VERTEX.LOCK)
		var vertex5: Node2D = graph.add_vertex("", TYPE_VERTEX.TASK)
		var vertex6: Node2D = graph.add_vertex("", TYPE_VERTEX.KEY)
		
		var direction: Vector2 = (vertex2.position - vertex1.position).normalized()
		var mirrorDirection: Vector2 = Vector2(direction.x * -1, direction.y) if direction.x != 0 else Vector2(direction.x, direction.y * -1)
		var targetPos: Vector2 = vertex1.position + (direction * cellSize)
		var targetPos2: Vector2 = targetPos + (direction * cellSize)
		#if that position has a vertex
		if graph.is_pos_has_placed(targetPos):
			graph.slide_vertices(targetPos, direction)
		if graph.is_pos_has_placed(targetPos2):
			graph.slide_vertices(targetPos2, direction)
		graph.change_vertex_pos(vertex3, targetPos)
		graph.change_vertex_pos(vertex4, targetPos2)
		
		chosenEdge.init_object(vertex1, vertex3, TYPE_EDGE.PATH, direction)
		graph.connect_vertex(vertex3, vertex4, TYPE_EDGE.PATH, direction)
		graph.connect_vertex(vertex4, vertex2, TYPE_EDGE.PATH, direction)
		
		var directionOptions: Array = []
		for option in DIRECTIONS:
			if vertex1.connections[option] == null and vertex3.connections[option] == null:
				directionOptions.append(option)
		var chosenOption: Vector2 = directionOptions[randi() % directionOptions.size()]
		print(chosenOption)
		var mirrorOption: Vector2 = Vector2(chosenOption.x * -1, chosenOption.y) if chosenOption.x != 0 else Vector2(chosenOption.x, chosenOption.y * -1)
		var targetPos3: Vector2 = vertex1.position + (chosenOption * cellSize)
		var targetPos4: Vector2 = vertex3.position + (chosenOption * cellSize)
		#if that position has a vertex
		if graph.is_pos_has_placed(targetPos3) and graph.is_pos_crossed_line(targetPos3):
			graph.slide_vertices(targetPos3, chosenOption)
		if graph.is_pos_has_placed(targetPos4) and graph.is_pos_crossed_line(targetPos4):
			graph.slide_vertices(targetPos4, chosenOption)
		graph.change_vertex_pos(vertex6, targetPos3)
		graph.change_vertex_pos(vertex5, targetPos4)
		
		graph.connect_vertex(vertex6, vertex1, TYPE_EDGE.PATH, mirrorOption)
		graph.connect_vertex(vertex3, vertex5, TYPE_EDGE.PATH, chosenOption)
		graph.connect_vertex(vertex5, vertex6, TYPE_EDGE.PATH, mirrorDirection)
		graph.connect_vertex(vertex6, vertex4, TYPE_EDGE.KEY_LOCK)
#		print("execute rule KL3 at" + str(chosenEdge))

func _rule_knl_4(graph: Node):
	var matchEdge: Array = []
	for edge in graph.get_edges():
		#check if there is 2 vertex connected and the secon vertex type is goal
		var from = graph.get_vertex(edge.from)
		var to = graph.get_vertex(edge.to)
		if !from.is_element() and to.type == TYPE_VERTEX.GOAL and edge.type != TYPE_EDGE.KEY_LOCK:
			matchEdge.append(edge)
	
	if matchEdge.size() > 0:
		var chosenEdge: Node2D = matchEdge[randi() % matchEdge.size()]
		var vertex1: Node2D = graph.get_vertex(chosenEdge.from)
		var vertex2: Node2D = graph.get_vertex(chosenEdge.to)
		var vertex3: Node2D = graph.add_vertex("", TYPE_VERTEX.KEY)
		var vertex4: Node2D = graph.add_vertex("", TYPE_VERTEX.TASK)
		var vertex5: Node2D = graph.add_vertex("", TYPE_VERTEX.LOCK)
		
		var direction: Vector2 = (vertex2.position - vertex1.position).normalized()
		var targetPos: Vector2 = vertex1.position + (direction * cellSize)
		var targetPos2: Vector2 = targetPos + (direction * cellSize)
		var targetPos3: Vector2 = targetPos2 + (direction * cellSize)
		#if that position has a vertex
		if graph.is_pos_has_placed(targetPos):
			graph.slide_vertices(targetPos, direction)
		if graph.is_pos_has_placed(targetPos2):
			graph.slide_vertices(targetPos2, direction)
		if graph.is_pos_has_placed(targetPos3):
			graph.slide_vertices(targetPos3, direction)
		graph.change_vertex_pos(vertex3, targetPos)
		graph.change_vertex_pos(vertex4, targetPos2)
		graph.change_vertex_pos(vertex5, targetPos3)
		
		chosenEdge.init_object(vertex1, vertex3, TYPE_EDGE.PATH, direction)
		graph.connect_vertex(vertex3, vertex4, TYPE_EDGE.PATH, direction)
		graph.connect_vertex(vertex4, vertex5, TYPE_EDGE.PATH, direction)
		graph.connect_vertex(vertex5, vertex2, TYPE_EDGE.PATH, direction)
		graph.connect_vertex(vertex3, vertex5, TYPE_EDGE.KEY_LOCK)
#		print("execute rule KL4 at" + str(chosenEdge))

func _random_init(graph: Node):
	var chosenrule = randi() % 2 + 1
	if chosenrule == 1:
		_rule_init_1(graph)
	else:
		_rule_init_2(graph)

func _random_extend(graph: Node):
	var chosenrule = randi() % 3 + 1
	if chosenrule == 1:
		_rule_extend_1(graph)
	elif chosenrule == 2:
		_rule_extend_2(graph)
	else:
		_rule_extend_3(graph)

func _random_knl(graph: Node):
	var chosenrule = randi() % 4 + 1
	match chosenrule:
		1: _rule_knl_1(graph)
		2: _rule_knl_2(graph)
		3: _rule_knl_3(graph)
		4: _rule_knl_4(graph)

# end of collection of rules ===================================================

# collection transform rule ====================================================
func _sub_off(vertex: Node2D, sub_vertex: Node2D):
	sub_vertex.subOf = vertex
	sub_vertex.add_to_group("subVertices")
	sub_vertex.connection_reset()
	vertex.subs.append(sub_vertex)
	#positioning sub vertices
	for i in range(vertex.subs.size()):
		var sub: Node2D = vertex.subs[i]
		sub.position = vertex.position + Vector2(32 + 16,0).rotated(deg2rad(i * 36))

func _create_entrance(graph: Node2D, vertex: Node2D):
	#create entrance
	if vertex.type == TYPE_VERTEX.START:
		var newVertex: Node2D = graph.add_vertex()
		graph.change_vertex_pos(newVertex, vertex.position)
		vertex.type = TYPE_VERTEX.ENTRANCE
		_sub_off(newVertex, vertex)
		graph.posVertices.erase(vertex.name)
		for edge in graph.get_edges_of(vertex):
			if edge.from == vertex:
				edge.from = newVertex
			elif edge.to == vertex:
				edge.to = newVertex
		newVertex.connections = vertex.connections.duplicate()
		graph.update()
#		var msg = "execute rule createEntrance at " + str(vertex) +" new "+str(newVertex)
#		print(msg)

func _create_goal(graph: Node2D, vertex: Node2D):
	#create goal
	if vertex.type == TYPE_VERTEX.GOAL:
		var newVertex: Node = graph.add_vertex()
		graph.change_vertex_pos(newVertex, vertex.position)
		_sub_off(newVertex, vertex)
		graph.posVertices.erase(vertex.name)
		for edge in graph.get_edges_of(vertex):
			if edge.from == vertex:
				edge.from = newVertex
			elif edge.to == vertex:
				edge.to = newVertex
		newVertex.connections = vertex.connections.duplicate()
		graph.update()
#		var msg = "execute rule createGoal at" + str(vertex) +" new "+str(newVertex)
#		print(msg)

func _create_secret(graph: Node2D, vertex: Node2D):
	#create secret
	if vertex.type == TYPE_VERTEX.SECRET:
		var newVertex: Node2D = graph.add_vertex()
		graph.change_vertex_pos(newVertex, vertex.position)
		_sub_off(newVertex, vertex)
		graph.posVertices.erase(vertex.name)
		for edge in graph.get_edges_of(vertex):
			if edge.from == vertex:
				edge.from = newVertex
			elif edge.to == vertex:
				edge.to = newVertex
#			edge.type = TYPE_EDGE.HIDDEN
		newVertex.connections = vertex.connections.duplicate()
		graph.update()
#		var msg = "execute rule createSecret at" + str(vertex) +" new "+str(newVertex)
#		print(msg)

func _outside_element_exist(graph: Node) -> bool:
	for vertex in graph.get_vertices():
		if vertex.is_element() and vertex.subOf == null:
			return true
	return false

func _add_element_before_place(graph: Node):
	var matchVertices: Array = []
	for vertex0 in graph.get_vertices():
		for vertex1 in graph.get_outgoing_vertex(vertex0, TYPE_EDGE.PATH):
			if !vertex0.is_element() and vertex1.is_element() and vertex1.subOf == null:
				matchVertices.append([vertex0, vertex1])
	# example
	if !matchVertices.empty():
		var choosenMatch = matchVertices[randi() % matchVertices.size()]
		_sub_off(choosenMatch[0], choosenMatch[1])
		graph.posVertices.erase(choosenMatch[1].name)
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
		graph.update()
#		var msg = "execute rule addElementBeforePlace at" + str(choosenMatch[0]) + str(choosenMatch[1])
#		print(msg)

func _add_lock_after_place(graph: Node):
	var matchVertices: Array = []
	for vertex0 in graph.get_vertices():
		for vertex1 in graph.get_outgoing_vertex(vertex0, TYPE_EDGE.PATH):
			if vertex0.type == TYPE_VERTEX.LOCK and vertex0.subOf == null and !vertex1.is_element():
				matchVertices.append([vertex0, vertex1])
	
	if matchVertices.size() > 0:
		var choosenMatch = matchVertices[randi() % matchVertices.size()]
		_sub_off(choosenMatch[1], choosenMatch[0])
		graph.posVertices.erase(choosenMatch[0].name)
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
		graph.update()
#		var msg = "execute rule addLockAfterPlace at" + str(choosenMatch[0]) + str(choosenMatch[1])
#		print(msg)

func _place_key_element(graph: Node):
	var matchVertices: Array = []
	for vertex0 in graph.get_vertices():
		for vertex1 in graph.get_outgoing_vertex(vertex0, TYPE_EDGE.PATH):
			if vertex0.type == TYPE_VERTEX.KEY and vertex0.subOf == null and !vertex1.is_element():
				matchVertices.append([vertex0, vertex1])
	
	if matchVertices.size() > 0:
		var choosenMatch = matchVertices[randi() % matchVertices.size()]
		var newVertex: Node2D = graph.add_vertex()
		graph.change_vertex_pos(newVertex, choosenMatch[0].position)
		_sub_off(newVertex, choosenMatch[0])
		graph.posVertices.erase(choosenMatch[0].name)
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
		graph.update()
#		var msg = "execute rule addLockAfterPlace at" + str(choosenMatch[0]) + str(choosenMatch[1])
#		print(msg)

func _add_element_after_place(graph: Node):
	var matchVertices: Array = []
	for vertex0 in graph.get_vertices():
		for vertex1 in graph.get_outgoing_vertex(vertex0, TYPE_EDGE.PATH):
			for vertex2 in graph.get_outgoing_vertex(vertex1, TYPE_EDGE.PATH):
				if vertex0.is_element() and vertex1.is_element() and vertex1.subOf == null and !vertex2.is_element():
					matchVertices.append([vertex0, vertex1, vertex2])
	
	if matchVertices.size() > 0:
		var choosenMatch = matchVertices[randi() % matchVertices.size()]
		_sub_off(choosenMatch[2], choosenMatch[1])
		graph.posVertices.erase(choosenMatch[1].name)
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
		graph.update()
#		var msg = "execute rule addLockAfterPlace at" + str(choosenMatch[0]) + str(choosenMatch[1]) + str(choosenMatch[2])
#		print(msg)

# end of collection transform rule =============================================
func _execute_rule(rule: String, graph: Node):
	match rule:
		"init1":
			_rule_init_1(graph)
		"init2":
			_rule_init_2(graph)
		"extend1":
			_rule_extend_1(graph)
		"extend2":
			_rule_extend_2(graph)
		"extend3":
			_rule_extend_3(graph)
		"secret":
			_rule_secret(graph)
		"obstacle":
			_rule_obstacle(graph)
		"reward":
			_rule_reward(graph)
		"key&lock1":
			_rule_knl_1(graph)
		"key&lock2":
			_rule_knl_2(graph)
		"key&lock3":
			_rule_knl_3(graph)
		"key&lock4":
			_rule_knl_4(graph)
		"randomInit":
			_random_init(graph)
		"randomExtend":
			_random_extend(graph)
		"randomKeyLock":
			_random_knl(graph)

func _execute_create_place_rule(graph: Node2D):
	#create place rule
	for vertex in graph.get_vertices():
		_create_entrance(graph, vertex)
		_create_goal(graph, vertex)
		_create_secret(graph, vertex)

func _execute_clean_outside_element_rule(graph: Node2D):
	#clean outside element rule
	while _outside_element_exist(graph):
		var execute: int = randi() % 4
		match execute:
			0: _add_element_before_place(graph)
			1: _add_lock_after_place(graph)
			2: _place_key_element(graph)
			3: _add_lock_after_place(graph)

func _execute_trim_position_vertices(graph: Node2D):
	#make element edge
	for edge in graph.get_edges():
		var from: Node2D = edge.from
		var to: Node2D = edge.to
		if from.type != TYPE_VERTEX.KEY and to.type != TYPE_VERTEX.LOCK:
			if from.is_element() or to.is_element():
				edge.type = TYPE_EDGE.ELEMENT
				edge.add_to_group("elementEdges")
	
	var verticesPos: PoolVector2Array = graph.posVertices.values()
	print("=============before=============")
	print("=============graph.posVertices=============")
	for obj in graph.posVertices:
		print(obj + str(graph.posVertices[obj]))
	print("=============verticesPos=============")
	for pos in verticesPos:
		print(pos)
	print("==========================")
	
	var lowestPos: Vector2 = Vector2(10000,10000) * cellSize
	var highestPos: Vector2 = Vector2(-10000,-10000) * cellSize
	for vertex in graph.get_vertices():
		if vertex.subOf == null:
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
	print("lowestPos " + str(lowestPos))
	print("highestPos " + str(highestPos))
	
	#rearrange position
	#x position
	while lowestPos.x <= highestPos.x:
		var found: bool = true
		for pos in verticesPos:
			if lowestPos.x == pos.x:
				found = false
				break
		if found:
			for i in range(verticesPos.size()):
				if verticesPos[i].x > lowestPos.x:
					verticesPos[i].x -= (1 * cellSize.x)
			highestPos.x -= (1 * cellSize.x)
		else:
			lowestPos.x += (1 * cellSize.x)
		print("lowestPos.x now " + str(lowestPos.x))
		print("highestPos.x now " + str(highestPos.x))
	#y position
	while lowestPos.y <= highestPos.y:
		var found: bool = true
		for pos in verticesPos:
			if lowestPos.y != pos.y:
				found = false
				break
		if found:
			for i in range(verticesPos.size()):
				if verticesPos[i].y > lowestPos.y:
					verticesPos[i].y -= (1 * cellSize.y)
			highestPos.y -= (1 * cellSize.y)
		else:
			lowestPos.y += (1 * cellSize.y)
	
	#update position
	var verticesName: PoolStringArray = graph.posVertices.keys()
	for i in range(verticesName.size()):
		graph.posVertices[verticesName[i]] = verticesPos[i]
	
	for vertex in graph.get_vertices():
		if vertex.subOf == null:
			print(str(vertex)+str(vertex.position)+" <- "+str(graph.posVertices.get(vertex.name)))
			graph.change_vertex_pos(vertex, graph.posVertices.get(vertex.name))
			print(str(vertex)+str(vertex.position))
	for subVertex in get_tree().get_nodes_in_group("subVertices"):
		subVertex.position = subVertex.subOf.position + Vector2(32 + 16,0).rotated(deg2rad(subVertex.subOf.subs.size() * 36))
	
	#re-connections vertex
	for edge in graph.get_edges():
		if edge.type == TYPE_EDGE.PATH and edge.from != null and edge.to != null:
			#non diagonal direction
			var direction: Vector2 = (edge.to.position - edge.from.position).normalized()
			if DIRECTIONS.has(direction):
				var mirror = Vector2(direction.x * -1, direction.y) if direction.x != 0 else Vector2(direction.x, direction.y * -1)
				edge.from.connections[direction] = edge.to
				edge.to.connections[mirror] = edge.from

func _execute_transform_rule(graph: Node2D):
	_execute_create_place_rule(graph)
	_execute_clean_outside_element_rule(graph)
	_execute_trim_position_vertices(graph)
	
	graph.update()

func _execute_single_transform_rule(graph: Node2D):
	if _outside_element_exist(graph):
		var execute: int = randi() % 4
		print(execute)
		match execute:
			0: _add_element_before_place(graph)
			1: _add_lock_after_place(graph)
			2: _place_key_element(graph)
			3: _add_lock_after_place(graph)

func _on_ButtonAddGraph_pressed():
	_create_graph()


func _on_OptionTargetGraph_item_selected(index):
	targetGraph = get_node("Graphs/" + $"%OptionTargetGraph".get_item_text(index))
	$"%OptionTargetGraph2".select($"%OptionTargetGraph".get_selected_id())


func _on_ButtonDeleteGraph_pressed():
	targetGraph.queue_free()
	targetGraph = null
	$"%OptionTargetGraph".remove_item($"%OptionTargetGraph".get_selected_id())
	$"%OptionTargetGraph2".remove_item($"%OptionTargetGraph".get_selected_id())
	$"%OptionTargetGraph".select(-1)
	$"%OptionTargetGraph2".select(-1)


func _on_ButtonExecuteSingleRule_pressed():
	var selectedRule = $"%OptionSingleRule".get_item_text($"%OptionSingleRule".get_selected_id())
	_execute_rule(selectedRule, targetGraph)


func _on_ButtonAddRule_pressed():
	var textItem = $"%OptionRuleRecipe".get_item_text($"%OptionRuleRecipe".get_selected_id())
	recipe.append(textItem)
	$"%RichTextRecipe".add_text(textItem)
	$"%RichTextRecipe".newline()


func _on_ButtonExecuteRecipe_pressed():
	for rule in recipe:
		_execute_rule(rule, targetGraph)


func _on_ButtonClearRecipe_pressed():
	recipe.clear()
	$"%RichTextRecipe".clear()


func _on_ButtonClearAll_pressed():
	for graph in graphs.get_children():
		graph.queue_free()
	targetGraph = null
	$"%OptionTargetGraph".clear()
	indexGraph = 0
	indexVertex = 0


func _on_OptionTargetGraph2_item_selected(index):
	targetGraph = get_node("Graphs/" + $"%OptionTargetGraph".get_item_text(index))
	$"%OptionTargetGraph".select($"%OptionTargetGraph2".get_selected_id())


func _on_ButtonGetInfo_pressed():
	if targetGraph != null:
		var fitness = targetGraph.get_fitness()
		$"%Labelvariation".text = "variation : " + str(targetGraph.variation)
		$"%Labelexploration".text = "exploration : " + str(targetGraph.exploration)
		$"%LabelshortesPathLength".text = "shortesPathLength : " + str(targetGraph.shortesPathLength)
		$"%LabelstandardShortPath".text = "standardShortPath : " + str(targetGraph.standardShortPath)
		$"%LabelweightDuration".text = "standardShortPath : " + str(targetGraph.weightDuration)
		$"%LabeloptionReplay".text = "optionReplay : " + str(targetGraph.optionReplay)
		$"%Labelfitness".text = "fitness : " + str(fitness)


func _on_ButtonTransform_pressed():
	_execute_transform_rule(targetGraph)

func _on_ButtonInitSingleTransform_pressed():
	_execute_create_place_rule(targetGraph)

func _on_ButtonSingleTransform_pressed():
	_execute_single_transform_rule(targetGraph)

func _on_ButtonTrimPosition_pressed():
	_execute_trim_position_vertices(targetGraph)
