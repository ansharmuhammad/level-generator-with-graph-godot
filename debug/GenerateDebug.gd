extends Node2D

onready var gui = $"%GUI"
onready var popup = $"%WindowDialogGenerator"
onready var popup2 = $"%WindowDialogGraph"
onready var optionTargetGraph = $"%OptionTargetGraph"
onready var optionTargetGraph2 = $"%OptionTargetGraph2"
onready var graphs = $"%Graphs"
onready var optionSingleRule = $"%OptionSingleRule"
onready var buttonExecuteSingleRule = $"%ButtonExecuteSingleRule"
onready var optionRuleRecipe = $"%OptionRuleRecipe"
onready var richTextRecipe = $"%RichTextRecipe"
onready var butttonExecuteRecipe = $"%ButtonExecuteRecipe"
onready var buttonTransformRule = $"%ButtonTransform"

const Graph = preload("res://debug/visualGraph/VisualGraph.tscn")
const Vertex = preload("res://debug/visualNode/VisualNode.tscn")
const Edge = preload("res://debug/visualEdge/VisualEdge.tscn")

var targetGraph: Node2D = null
var indexGraph: int = 0
var indexVertex: int = 0
var recipe: Array = [
	"randomInit",
	"randomExtend", "randomExtend", "randomExtend",
	"secret",
	"obstacle", "obstacle",
	"reward", "reward", "reward",
	"randomKeyLock", "randomKeyLock", "randomKeyLock"
]

var gridSize: float = 300

# Called when the node enters the scene tree for the first time.
func _ready():
	for rule in recipe:
		richTextRecipe.add_text(rule)
		richTextRecipe.newline()
	randomize()

func _input(event):
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == BUTTON_RIGHT:
		var mouse = get_viewport().get_mouse_position()
		if !event.control:
			popup.popup(Rect2(mouse.x, mouse.y, popup.rect_size.x, popup.rect_size.y))
		else:
			popup2.popup(Rect2(mouse.x, mouse.y, popup.rect_size.x, popup.rect_size.y))

#disable for performance
func _physics_process(delta):
	if targetGraph == null:
		buttonExecuteSingleRule.disabled = true
		butttonExecuteRecipe.disabled = true
		buttonTransformRule.disabled = true
	else:
		buttonExecuteSingleRule.disabled = false
		butttonExecuteRecipe.disabled = false
		buttonTransformRule.disabled = false

# collection of rules ==========================================================

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
		var rad = vertex1.colShape.get_shape().radius * 2

		var vertex2 = graph.add_vertex()
#		vertex2.position = vertex1.position + (Vector2.RIGHT * rad)
		vertex2.position = vertex1.position + (Vector2(gridSize, 0))
		var vertex3 = graph.add_vertex("",TYPE_VERTEX.GOAL)
#		vertex3.position = vertex2.position + (Vector2.DOWN * rad)
		vertex3.position = vertex2.position + (Vector2(0, gridSize))
		var vertex4 = graph.add_vertex()
#		vertex4.position = vertex1.position + (Vector2.DOWN * rad)
		vertex4.position = vertex1.position + (Vector2(0, gridSize))

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
		var rad = vertex1.colShape.get_shape().radius * 2
		
		var vertex2 = graph.add_vertex()
		vertex2.position = vertex1.position + (Vector2(gridSize, 0))
		var vertex3 = graph.add_vertex()
		vertex3.position = vertex2.position + (Vector2(gridSize, 0))
		var vertex4 = graph.add_vertex()
		vertex4.position = vertex3.position + (Vector2(0, gridSize))
		var vertex5 = graph.add_vertex("",TYPE_VERTEX.GOAL)
		vertex5.position = vertex4.position + (Vector2(gridSize, 0))
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
		vertex2.position = vertex2.position - Vector2(gridSize,0).rotated(vertex2.position.angle_to_point(vertex1.position))
		vertex3.position = (vertex1.position + vertex2.position)/2
		
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
		var rad = vertex1.colShape.get_shape().radius * 2
		var vertex2 = graph.add_vertex("",TYPE_VERTEX.SECRET)
		
		if idx == 0:
			vertex2.position = from.position + Vector2(rad, 0).rotated(from.position.angle_to_point(to.position) + deg2rad(-90))
		else:
			vertex2.position = to.position + Vector2(rad, 0).rotated(to.position.angle_to_point(from.position) + deg2rad(-90))
		
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
		var rad = vertex1.colShape.get_shape().radius * 2
		
		var vertex3 = graph.add_vertex("", TYPE_VERTEX.TASK)
		vertex3.position = (vertex1.position + vertex2.position)/2
		var vertex4 = graph.add_vertex("", TYPE_VERTEX.LOCK)
		vertex4.position = (vertex3.position + vertex2.position)/2
		var vertex5 = graph.add_vertex("", TYPE_VERTEX.KEY)
		vertex5.position = vertex3.position + Vector2(rad, 0).rotated(vertex3.position.angle_to_point(vertex1.position) + deg2rad(-90))
		var vertex6 = graph.add_vertex("", TYPE_VERTEX.TASK)
		vertex6.position = vertex1.position + Vector2(rad, 0).rotated(vertex1.position.angle_to_point(vertex3.position) + deg2rad(90))
		
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
		var rad = vertex1.colShape.get_shape().radius * 2
		var vertex2 = graph.get_vertex(chosenEdge.to)
		
		var vertex3 = graph.add_vertex("", TYPE_VERTEX.TASK)
		vertex3.position = (vertex1.position + vertex2.position)/2
		var vertex4 = graph.add_vertex("", TYPE_VERTEX.LOCK)
		vertex4.position = (vertex3.position + vertex2.position)/2
		var vertex5 = graph.add_vertex("", TYPE_VERTEX.TASK)
		vertex5.position = vertex3.position + Vector2(rad, 0).rotated(vertex3.position.angle_to_point(vertex1.position) + deg2rad(-90))
		var vertex6 = graph.add_vertex("", TYPE_VERTEX.KEY)
		vertex6.position = vertex1.position + Vector2(rad, 0).rotated(vertex1.position.angle_to_point(vertex3.position) + deg2rad(90))
		
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

# end of collection of rules ===================================================

# collection transform rule ====================================================
func _sub_off(vertex: RigidBody2D, sub_vertex: RigidBody2D):
	vertex.colShape.disabled = true
	sub_vertex.colShape.disabled = true
	
	vertex.set_mode(RigidBody2D.MODE_KINEMATIC)
	vertex.alwaysStatic = true
	
	sub_vertex.set_mode(RigidBody2D.MODE_RIGID)
	
	sub_vertex.subOf = vertex
	sub_vertex.isElement = true
	sub_vertex.colShape.set_shape(sub_vertex.shapeSmall)
	sub_vertex.change_layer(2)
	sub_vertex.set_scale_node(1)
	sub_vertex.global_position = vertex.global_position + Vector2(vertex.colShape.shape.radius, vertex.colShape.shape.radius)
	sub_vertex.move = true
	var _radius = vertex.colShape.shape.radius
	sub_vertex.newPos = vertex.global_position + Vector2(_radius-50,_radius-50).rotated(deg2rad(30) * vertex.sub.size())
	vertex.sub.append(sub_vertex.name)
	
	yield(get_tree(), "physics_frame")
	var pinjoint = PinJoint2D.new()
	vertex.add_child(pinjoint)
	pinjoint.global_position = vertex.global_position
	pinjoint.name = str(vertex.name)+"joint"+str(sub_vertex.name)
#	pinjoint.disable_collision = false
	pinjoint.softness = 16
#	pinjoint.bias = 0.9
	sub_vertex.colShape.disabled = false
	pinjoint.node_a = vertex.get_path()
	pinjoint.node_b = sub_vertex.get_path()
	vertex.colShape.disabled = false

#func _sub_off_alt(vertex: RigidBody2D, sub_vertex: RigidBody2D):
#

func _create_entrance(graph: Node, vertex: Node):
	#create entrance
	if vertex.type == TYPE_VERTEX.START:
		var newVertex: Node = graph.add_vertex()
		newVertex.position = vertex.position
		vertex.change_type(TYPE_VERTEX.ENTRANCE)
		_sub_off(newVertex, vertex)
		for edge in graph.get_edges_of(vertex):
			if edge.from == vertex:
				edge.from = newVertex
			elif edge.to == vertex:
				edge.to = newVertex
#		var msg = "execute rule createEntrance at " + str(vertex) +" new "+str(newVertex)
#		print(msg)

func _create_goal(graph: Node, vertex: Node):
	#create goal
	if vertex.type == TYPE_VERTEX.GOAL:
		var newVertex: Node = graph.add_vertex()
		newVertex.position = vertex.position
		_sub_off(newVertex, vertex)
		for edge in graph.get_edges_of(vertex):
			if edge.from == vertex:
				edge.from = newVertex
			elif edge.to == vertex:
				edge.to = newVertex
#		var msg = "execute rule createGoal at" + str(vertex) +" new "+str(newVertex)
#		print(msg)

func _create_secret(graph: Node, vertex: Node):
	#create secret
	if vertex.type == TYPE_VERTEX.SECRET:
		var newVertex: Node = graph.add_vertex()
		newVertex.position = vertex.position
		_sub_off(newVertex, vertex)
		for edge in graph.get_edges_of(vertex):
			if edge.from == vertex:
				edge.from = newVertex
			elif edge.to == vertex:
				edge.to = newVertex
#		var msg = "execute rule createSecret at" + str(vertex) +" new "+str(newVertex)
#		print(msg)

func _outside_element_exist(graph: Node) -> bool:
	for vertex in graph.get_vertices():
		if graph.is_element(vertex) and vertex.subOf == null:
			return true
	return false

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
		_sub_off(choosenMatch[0], choosenMatch[1])
		for edge in graph.get_edges_of(choosenMatch[1], TYPE_EDGE.PATH):
			if edge.from == choosenMatch[0] and edge.to == choosenMatch[1]:
				edge.queue_free()
			elif edge.from == choosenMatch[1]:
				var theVertex: Node = graph.get_vertex(edge.to)
				if graph.is_place(theVertex):
					edge.from = choosenMatch[0]
				else:
					edge.type = TYPE_EDGE.ELEMENT
					graph.connect_vertex(choosenMatch[0], theVertex)
			elif edge.to == choosenMatch[1]:
				var theVertex: Node = graph.get_vertex(edge.from)
				if graph.is_place(theVertex):
					edge.to = choosenMatch[0]
				else:
					edge.type = TYPE_EDGE.ELEMENT
					graph.connect_vertex(theVertex, choosenMatch[0])
#		var msg = "execute rule addElementBeforePlace at" + str(choosenMatch[0]) + str(choosenMatch[1])
#		print(msg)

func _add_lock_after_place(graph: Node):
	var matchVertices: Array = []
	for vertex1 in graph.get_vertices():
		for vertex2 in graph.get_outgoing_vertex(vertex1, TYPE_EDGE.PATH):
			if vertex1.type == TYPE_VERTEX.LOCK and graph.is_place(vertex2):
				matchVertices.append([vertex1, vertex2])
	
	if matchVertices.size() > 0:
		randomize()
		var choosenMatch = matchVertices[randi() % matchVertices.size()]
		_sub_off(choosenMatch[1], choosenMatch[0])
		for edge in graph.get_edges_of(choosenMatch[0], TYPE_EDGE.PATH):
			if edge.from == choosenMatch[0] and edge.to == choosenMatch[1]:
				edge.queue_free()
			elif edge.from == choosenMatch[0]:
				var theVertex: Node = graph.get_vertex(edge.to)
				if graph.is_place(theVertex):
					edge.from = choosenMatch[1]
				else:
					edge.type = TYPE_EDGE.ELEMENT
					graph.connect_vertex(choosenMatch[1], theVertex)
			elif edge.to == choosenMatch[0]:
				var theVertex: Node = graph.get_vertex(edge.from)
				if graph.is_place(theVertex):
					edge.to = choosenMatch[1]
				else:
					edge.type = TYPE_EDGE.ELEMENT
					graph.connect_vertex(theVertex, choosenMatch[1])
#		var msg = "execute rule addLockAfterPlace at" + str(choosenMatch[0]) + str(choosenMatch[1])
#		print(msg)

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
		_sub_off(newVertex, choosenMatch[0])
		for edge in graph.get_edges_of(choosenMatch[0], TYPE_EDGE.PATH):
			if edge.from == choosenMatch[0]:
				var theVertex: Node = graph.get_vertex(edge.to)
				if graph.is_place(theVertex):
					edge.from = newVertex
				else:
					edge.type = TYPE_EDGE.ELEMENT
					graph.connect_vertex(newVertex, theVertex)
			elif edge.to == choosenMatch[0]:
				var theVertex: Node = graph.get_vertex(edge.from)
				if graph.is_place(theVertex):
					edge.to = newVertex
				else:
					edge.type = TYPE_EDGE.ELEMENT
					graph.connect_vertex(theVertex, newVertex)
#		var msg = "execute rule addLockAfterPlace at" + str(choosenMatch[0]) + str(choosenMatch[1])
#		print(msg)

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
		_sub_off(choosenMatch[2], choosenMatch[1])
		for edge in graph.get_edges_of(choosenMatch[1], TYPE_EDGE.PATH):
			if edge.from == choosenMatch[1] and edge.to == choosenMatch[2]:
				edge.queue_free()
			if edge.from == choosenMatch[1]:
				var theVertex: Node = graph.get_vertex(edge.to)
				if graph.is_place(theVertex):
					edge.from = choosenMatch[2]
				else:
					edge.type = TYPE_EDGE.ELEMENT
					graph.connect_vertex(choosenMatch[2], theVertex)
			elif edge.to == choosenMatch[1]:
				var theVertex: Node = graph.get_vertex(edge.from)
				if graph.is_place(theVertex):
					edge.to = choosenMatch[2]
				else:
					edge.type = TYPE_EDGE.ELEMENT
					graph.connect_vertex(theVertex, choosenMatch[2])
#		var msg = "execute rule addLockAfterPlace at" + str(choosenMatch[0]) + str(choosenMatch[1]) + str(choosenMatch[2])
#		print(msg)

func _element_edges(graph: Node):
	for edge in graph.get_edges():
		if graph.get_vertex(edge.from).type != TYPE_VERTEX.KEY and graph.get_vertex(edge.to).type != TYPE_VERTEX.LOCK:
			if graph.is_element(graph.get_vertex(edge.from)) or graph.is_element(graph.get_vertex(edge.to)):
				edge.type = TYPE_EDGE.ELEMENT

func _execute_transform_rule(graph: Node):
	#create place rule
	for vertex in graph.get_vertices():
		_create_entrance(graph, vertex)
		_create_goal(graph, vertex)
		_create_secret(graph, vertex)
	
	#clean outside element rule
	while _outside_element_exist(graph):
		var execute: int = randi() % 4
		match execute:
			0: _add_element_before_place(graph)
			1: _add_lock_after_place(graph)
			2: _place_key_element(graph)
			3: _add_lock_after_place(graph)
#
	_element_edges(graph)
	#transformative rule

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
			var chosenrule = randi() % 2 + 1
			if chosenrule == 1:
				_rule_init_1(graph)
			else:
				_rule_init_2(graph)
		"randomExtend":
			var chosenrule = randi() % 3 + 1
			if chosenrule == 1:
				_rule_extend_1(graph)
			elif chosenrule == 2:
				_rule_extend_2(graph)
			else:
				_rule_extend_3(graph)
		"randomKeyLock":
			var chosenrule = randi() % 4 + 1
			match chosenrule:
				1: _rule_knl_1(graph)
				2: _rule_knl_2(graph)
				3: _rule_knl_3(graph)
				4: _rule_knl_4(graph)


# add new graph
func _on_ButtonAddGraph_pressed():
	#make graph
	var graph = Graph.instance()
	graph.init_object("graph"+str(indexGraph), indexGraph)
	var pos = indexGraph * 4500
	graph.global_position = graph.global_position + Vector2(pos, 0)
	
	#initiate vertex 
#	var vertexinit = Vertex.instance()
	var vertexinit = graph.add_vertex("",TYPE_VERTEX.INIT)
#	vertexinit.init_object("Node" + str(graph.indexVertex), TYPE_VERTEX.INIT)
	vertexinit.newPos = graph.global_position
	vertexinit.move = true
	yield(get_tree(), "physics_frame")
	graph.get_node("Vertices").add_child(vertexinit)
#	graph.indexVertex += 1
	graph.connect_vertex(vertexinit, null)
	graphs.add_child(graph)
	
	#add to option
	optionTargetGraph.add_item(graph.name, indexGraph)
	optionTargetGraph.select(indexGraph)
	optionTargetGraph2.add_item(graph.name, indexGraph)
	optionTargetGraph2.select(indexGraph)
	targetGraph = graph
	indexGraph += 1


func _on_OptionTargetGraph_item_selected(index):
	targetGraph = get_node("Graphs/" + optionTargetGraph.get_item_text(index))
	optionTargetGraph2.select(optionTargetGraph.get_selected_id())

func _on_OptionTargetGraph2_item_selected(index):
	targetGraph = get_node("Graphs/" + optionTargetGraph.get_item_text(index))
	optionTargetGraph.select(optionTargetGraph2.get_selected_id())

func _on_ButtonExecuteSingleRule_pressed():
	var selectedRule = optionSingleRule.get_item_text(optionSingleRule.get_selected_id())
	_execute_rule(selectedRule, targetGraph)


func _on_ButtonClearAll_pressed():
	for graph in graphs.get_children():
		graph.queue_free()
	targetGraph = null
	optionTargetGraph.clear()
	indexGraph = 0
	indexVertex = 0


func _on_ButtonAddRule_pressed():
	var textItem = optionRuleRecipe.get_item_text(optionRuleRecipe.get_selected_id())
	recipe.append(textItem)
	richTextRecipe.add_text(textItem)
	richTextRecipe.newline()


func _on_ButtonClearRecipe_pressed():
	recipe.clear()
	richTextRecipe.clear()


func _on_ButtonExecuteRecipe_pressed():
	for rule in recipe:
		_execute_rule(rule, targetGraph)


func _on_ButtonTransform_pressed():
	_execute_transform_rule(targetGraph)


func _on_ButtonDeleteGraph_pressed():
	targetGraph.queue_free()
	targetGraph = null
	optionTargetGraph.remove_item(optionTargetGraph.get_selected_id())
	optionTargetGraph2.remove_item(optionTargetGraph.get_selected_id())
	optionTargetGraph.select(-1)
	optionTargetGraph2.select(-1)


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


func _on_ButtonToggleLineElement2_toggled(button_pressed):
	for edge in targetGraph.get_edges():
		if edge.type != TYPE_EDGE.PATH:
			edge.showLine = button_pressed


func _on_ButtonToggleNodeElement_toggled(button_pressed):
	for vertex in targetGraph.get_vertices():
		if vertex.isElement:
			vertex.visible = button_pressed


func _on_ButtonToggleSnap_toggled(button_pressed):
	for vertex in targetGraph.get_vertices():
		if !vertex.isElement:
			vertex.snap = true
