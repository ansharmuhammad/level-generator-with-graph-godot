extends Node2D

onready var gui = $"%GUI"
onready var popup = $"%WindowDialog"
onready var optionTargetGraph = $"%OptionTargetGraph"
onready var graphs = $Graphs
onready var optionSingleRule = $"%OptionSingleRule"
onready var buttonExecuteSingleRule = $"%ButtonExecuteSingleRule"

const Graph = preload("res://debug/visualGraph/VisualGraph.tscn")
const Vertex = preload("res://debug/visualNode/VisualNode.tscn")
const Edge = preload("res://debug/visualEdge/VisualEdge.tscn")

var targetGraph: Node2D
onready var indexGraph: int = 0
onready var indexVertex: int = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()

func _input(event):
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == BUTTON_RIGHT:
		var mouse = get_viewport().get_mouse_position()
		popup.popup(Rect2(mouse.x, mouse.y, popup.rect_size.x, popup.rect_size.y))

# collection of rules ==========================================================

func ruleInit1(graph: Node):
	var match_edge: Array = []
	for edge in graph.get_node("Edges").get_children():
		#check if there is init vertex
		var from = graph.get_vertex(edge.from)		
		if from.type == TYPE_VERTEX.INIT and edge.to == null:
			match_edge.append(edge)

	if match_edge.size() > 0:
		var chosenEdge = match_edge[randi() % match_edge.size()]
		var vertex1 = graph.get_vertex(chosenEdge.from)
		vertex1.type = TYPE_VERTEX.START
		vertex1.labelType.text = "S"
		var rad = vertex1.colShape.get_shape().radius * 2

		var vertex2 = graph.add_vertex()
		vertex2.position = vertex1.position + (Vector2.RIGHT * rad)
		var vertex3 = graph.add_vertex("",TYPE_VERTEX.GOAL)
		vertex3.position = vertex2.position + (Vector2.DOWN * rad)
		var vertex4 = graph.add_vertex()
		vertex4.position = vertex1.position + (Vector2.DOWN * rad)

		chosenEdge.init(vertex1, vertex2)
		graph.connect_vertex(vertex2, vertex3)
		graph.connect_vertex(vertex3, vertex4)
		graph.connect_vertex(vertex4, vertex1)
#		print("execute rule init1 at" + str(chosenEdge))

func ruleInit2(graph: Node):
	var match_edge: Array = []
	for edge in graph.get_node("Edges").get_children():
		#check if there is init vertex
		var from = graph.get_vertex(edge.from)		
		if from.type == TYPE_VERTEX.INIT and edge.to == null:
			match_edge.append(edge)

	if match_edge.size() > 0:
		var chosenEdge = match_edge[randi() % match_edge.size()]
		var vertex1 = graph.get_vertex(chosenEdge.from)
		vertex1.type = TYPE_VERTEX.START
		vertex1.labelType.text = "S"
		var rad = vertex1.colShape.get_shape().radius * 2
		
		var vertex2 = graph.add_vertex()
		vertex2.position = vertex1.position + (Vector2.RIGHT * rad)
		var vertex3 = graph.add_vertex()
		vertex3.position = vertex2.position + (Vector2.RIGHT * rad)
		var vertex4 = graph.add_vertex()
		vertex4.position = vertex3.position + (Vector2.DOWN * rad)
		var vertex5 = graph.add_vertex("",TYPE_VERTEX.GOAL)
		vertex5.position = vertex4.position + (Vector2.RIGHT * rad)
		var vertex6 = graph.add_vertex()
		vertex6.position = vertex4.position + (Vector2.LEFT * rad)
		
		chosenEdge.init(vertex1, vertex2)
		graph.connect_vertex(vertex2, vertex3)
		graph.connect_vertex(vertex3, vertex4)
		graph.connect_vertex(vertex4, vertex5)
		graph.connect_vertex(vertex4, vertex6)
		graph.connect_vertex(vertex6, vertex2)
#		print("execute rule init2 at" + str(chosenEdge))

func ruleExtend1(graph: Node):
	var match_edge: Array = []
	for edge in graph.get_node("Edges").get_children():
		#check if there is 2 vertex connected
		if edge.type == TYPE_EDGE.PATH:
			match_edge.append(edge)

	if match_edge.size() > 0:
		var chosenEdge = match_edge[randi() % match_edge.size()]
		var vertex1 = graph.get_vertex(chosenEdge.from)
		var vertex2 = graph.get_vertex(chosenEdge.to)
		var vertex3 = graph.add_vertex()
		vertex3.position = (vertex1.position + vertex2.position)/2
		
		chosenEdge.init(vertex1, vertex3)
		graph.connect_vertex(vertex3, vertex2)
#		print("execute rule Extend1 at" + str(chosenEdge))

func ruleExtend2(graph: Node):
	var match_edge: Array = []
	for edge in graph.get_node("Edges").get_children():
		#check if there is 2 vertex connected
		if edge.type == TYPE_EDGE.PATH:
			match_edge.append(edge)

	if match_edge.size() > 0:
		var chosenEdge = match_edge[randi() % match_edge.size()]
		var vertex1 = graph.get_vertex(chosenEdge.from)
		var rad = vertex1.colShape.get_shape().radius * 2
		var vertex2 = graph.get_vertex(chosenEdge.to)
		var vertex3 = graph.add_vertex()
		var vertex4 = graph.add_vertex()
		vertex4.position = vertex1.position + Vector2(rad, 0).rotated(vertex1.position.angle_to_point(vertex2.position) + deg2rad(90))
		vertex3.position = vertex2.position + Vector2(rad, 0).rotated(vertex2.position.angle_to_point(vertex1.position) + deg2rad(-90))
		
		graph.connect_vertex(vertex1, vertex4)
		graph.connect_vertex(vertex4, vertex3)
		graph.connect_vertex(vertex3, vertex2)
#		print("execute rule Extend2 at" + str(chosenEdge))

func ruleExtend3(graph: Node):
	var match_edge: Array = []
	for edge in graph.get_node("Edges").get_children():
		#check if there is 2 vertex connected
		if edge.type == TYPE_EDGE.PATH:
			match_edge.append(edge)

	if match_edge.size() > 0:
		var chosenEdge = match_edge[randi() % match_edge.size()]
		var vertex1 = graph.get_vertex(chosenEdge.from)
		var rad = vertex1.colShape.get_shape().radius * 2
		var vertex2 = graph.get_vertex(chosenEdge.to)
		var vertex3 = graph.add_vertex()
		var vertex4 = graph.add_vertex()
		vertex3.position = vertex2.position + Vector2(rad, 0).rotated(vertex2.position.angle_to_point(vertex1.position) + deg2rad(-90))
		vertex4.position = vertex1.position + Vector2(rad, 0).rotated(vertex1.position.angle_to_point(vertex2.position) + deg2rad(90))
		
		graph.connect_vertex(vertex2, vertex3)
		graph.connect_vertex(vertex3, vertex4)
		graph.connect_vertex(vertex4, vertex1)
#		print("execute rule Extend2 at" + str(chosenEdge))

func ruleSecret(graph: Node):
	var match_edge: Array = []
	for edge in graph.get_node("Edges").get_children():
		#check if there is init vertex
		var from = graph.get_vertex(edge.from)
		var to = graph.get_vertex(edge.to)
		if (from.type == TYPE_VERTEX.TASK or to.type == TYPE_VERTEX.TASK) and edge.type == TYPE_EDGE.PATH:
			match_edge.append(edge)
	
	if match_edge.size() > 0:
		var chosenEdge = match_edge[randi() % match_edge.size()]
		var from = graph.get_vertex(chosenEdge.from)
		var to = graph.get_vertex(chosenEdge.to)
		
		var arrayVertex: Array = []
		if from.type == TYPE_VERTEX.TASK:
			arrayVertex.append(from)
		if to.type == TYPE_VERTEX.TASK:
			arrayVertex.append(to)
		
		var idx = randi() % arrayVertex.size()
		var vertex1 = arrayVertex[idx]
		var rad = vertex1.colShape.get_shape().radius * 2
		var vertex2 = graph.add_vertex("",TYPE_VERTEX.SECRET)
		
		if idx == 0:
			print("0")
			vertex2.position = from.position + Vector2(rad, 0).rotated(from.position.angle_to_point(to.position) + deg2rad(-90))
		else:
			print("1")
			vertex2.position = to.position + Vector2(rad, 0).rotated(to.position.angle_to_point(from.position) + deg2rad(-90))
		
		graph.connect_vertex(vertex1, vertex2)
#		print("execute rule Secret at" + str(chosenEdge) + "detail : " + vertex1.name)

func ruleObstacle(graph: Node):
	var match_edge: Array = []
	for edge in graph.get_node("Edges").get_children():
		#check if there is 2 vertex connected
		if edge.to != null:
			match_edge.append(edge)
	
	if match_edge.size() > 0:
		var chosenEdge = match_edge[randi() % match_edge.size()]
		var vertex1 = graph.get_vertex(chosenEdge.from)
		var vertex2 = graph.get_vertex(chosenEdge.to)
		var vertex3 = graph.add_vertex("", TYPE_VERTEX.OBSTACLE)
		vertex3.position = (vertex1.position + vertex2.position)/2
		
		chosenEdge.init(vertex1, vertex3)
		graph.connect_vertex(vertex3, vertex2)
#		print("execute rule Obstacle at" + str(chosenEdge))

func ruleReward(graph: Node):
	var match_edge: Array = []
	for edge in graph.get_node("Edges").get_children():
		#check if there is 2 vertex connected
		if edge.to != null:
			match_edge.append(edge)
	
	if match_edge.size() > 0:
		var chosenEdge = match_edge[randi() % match_edge.size()]
		var vertex1 = graph.get_vertex(chosenEdge.from)
		var vertex2 = graph.get_vertex(chosenEdge.to)
		var vertex3 = graph.add_vertex("", TYPE_VERTEX.OBSTACLE)
		var vertex4 = graph.add_vertex("", TYPE_VERTEX.REWARD)
		vertex3.position = (vertex1.position + vertex2.position)/2
		vertex4.position = (vertex3.position + vertex2.position)/2
		
		chosenEdge.init(vertex1, vertex3)
		graph.connect_vertex(vertex3, vertex4)
		graph.connect_vertex(vertex4, vertex2)
#		print("execute rule Reward at" + str(chosenEdge))

# end of collection of rules ===================================================

# add new graph
func _on_ButtonAddGraph_pressed():
	#make graph
	var graph = Graph.instance()
	graph.init("graph"+str(indexGraph), indexGraph)
	#initiate vertex 
	var vertexinit = Vertex.instance()
	vertexinit.init("Node" + str(indexVertex), TYPE_VERTEX.INIT)
	graph.get_node("Vertices").add_child(vertexinit)
	indexVertex += 1
	graph.connect_vertex(vertexinit, null)
	graphs.add_child(graph)
	
	#add to option
	optionTargetGraph.add_item(graph.name, indexGraph)
	optionTargetGraph.select(indexGraph)
	targetGraph = graph
	indexGraph += 1


func _on_OptionTargetGraph_item_selected(index):
	targetGraph = get_node("Graphs/" + optionTargetGraph.get_item_text(index))
	

func _on_ButtonExecuteSingleRule_pressed():
	var selectedRule = optionSingleRule.get_item_text(optionSingleRule.get_selected_id())
	match selectedRule:
		"init1":
			ruleInit1(targetGraph)
		"init2":
			ruleInit2(targetGraph)
		"extend1":
			ruleExtend1(targetGraph)
		"extend2":
			ruleExtend2(targetGraph)
		"extend3":
			ruleExtend3(targetGraph)
		"secret":
			ruleSecret(targetGraph)
		"obstacle":
			ruleObstacle(targetGraph)
		"reward":
			ruleReward(targetGraph)
