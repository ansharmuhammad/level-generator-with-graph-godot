extends Node2D

const Vertex = preload("res://lite/vertex/Vertex.tscn")
const Edge = preload("res://lite/edge/Edge.tscn")

## object function value
onready var variation: float = 0.0
onready var exploration: int = 0 #???
onready var shortesPathLength: int = 0
onready var standardShortPath: float = 0.0
onready var weightDuration: float = 0.0
onready var optionReplay: float = 0.0

## fitness function value
onready var fitness: float = 0.0

var index: int = 0
var indexNode: int = 0

# draw var
export var gridSize: Vector2 = Vector2(20,20)
var cellSize: Vector2 = Vector2(256,256)
var font
export var vertexRadius: float = 32
export var vertexOuterRadius: float = 64
export var vertexSubRadius: float
export var lineSize: float = 8


func _ready():
	font = DynamicFont.new()
	font.font_data = load("res://assets/seguihis.ttf")
	font.size = 32

func init_object(_name: String, _index: int):
	name = _name
	$Label.text = _name
	index = _index

# (1) generic method for a graph ===============================================

## get all vertices in graph
func get_vertices() -> Array:
	return $Vertices.get_children()

## get all edges in graph
func get_edges() -> Array:
	return $Edges.get_children()

## get list edges on a vertex
func get_edges_of(vertex: Node2D, type: String = "") -> Array:
	var listEdge: Array = []
	for edge in $Edges.get_children():
		if edge.from == vertex or edge.to == vertex:
			if type == "":
				listEdge.append(edge)
			elif edge.type == type:
				listEdge.append(edge)
	return listEdge

## add vertex to graph
func add_vertex(name: String = "", type: String = "") -> Node2D:
#	var _name = "Node" + str($Vertices.get_child_count()) if name == "" else name
	var _name = "Node" + str(indexNode) if name == "" else name
	indexNode += 1
	var _type = TYPE_VERTEX.TASK if type == "" else type
	var vertex = Vertex.instance()
	vertex.init_object(_name, _type)
	$Vertices.add_child(vertex)
	return vertex

func change_vertex_pos(vertex: Node2D, _position: Vector2):
	vertex.position = _position
	update()

## connecting between two vertex in graph with an edge
func connect_vertex(from: Node2D, to: Node2D, type: String = "", direction: Vector2 = Vector2.ZERO) -> Node2D:
	var edge = Edge.instance()
	var _type = type if type != "" else TYPE_EDGE.PATH
	edge.init_object(from, to, _type)
	if direction != Vector2.ZERO:
		var mirror: Vector2 = direction
		mirror = Vector2(mirror.x * -1, mirror.y) if mirror.x != 0 else Vector2(mirror.x, mirror.y * -1)
		from.connections[direction] = to
		to.connections[mirror] = from
	$Edges.add_child(edge)
	update()
	return edge

## get vertex object by its name
func get_vertex_by_name(vertexName: String) -> Node:
	return $Vertices.get_node(vertexName)

func get_vertex_by_position(_position: Vector2) -> Node:
	$RayCast2D.position = _position - Vector2(0,30)
	$RayCast2D.force_raycast_update()
	if $RayCast2D.is_colliding():
		return $RayCast2D.get_collider().get_parent()
	else:
		 return null

## get vertex object by its name
func get_vertex(vertex: Node2D) -> Node:
	return $Vertices.get_node(vertex.name)

func is_place(vertex: Node) -> bool:
	if vertex.type == TYPE_VERTEX.TASK or vertex.type == TYPE_VERTEX.SECRET:
		return true
	return false

func is_element(vertex: Node) -> bool:
	var element: Array = [
		TYPE_VERTEX.KEY,
		TYPE_VERTEX.LOCK,
		TYPE_VERTEX.OBSTACLE,
		TYPE_VERTEX.REWARD
	]
	return true if element.find(vertex.type) != -1 else false

## get list of outgoing edges on a vertex
func get_outgoing_edges(vertex: Node, type: String = "") -> Array:
	var listEdge: Array = []
	for edge in $Edges.get_children():
		if edge.from == vertex:
			if type == "":
				listEdge.append(edge)
			elif edge.type == type:
				listEdge.append(edge)
	return listEdge

## get list outgoing edges on a vertex
func get_outgoing_vertex(vertex: Node, typeEdge: String = "") -> Array:
	var listVertex: Array = []
	var edges: Array = get_outgoing_edges(vertex, typeEdge)
	for edge in edges:
		var toVertex: Node = get_vertex(edge.to)
		if listVertex.find(toVertex) == -1:
			listVertex.append(toVertex)
	return listVertex

## get sum of outgoing edges on a vertex
func get_outdegree(vertex: Node, typeEdge: String = "") -> int:
	return get_outgoing_edges(vertex, typeEdge).size()
# (1) end ======================================================================

# (2) function fitness =========================================================
func get_variation():
	var Ed: float = 0
	var edges: Array = []
	edges.append_array($Edges.get_children())
	for edge in edges:
		var from = get_vertex(edge.from)
		var to = get_vertex(edge.to)
		if (from.type != TYPE_VERTEX.START or from.type != TYPE_VERTEX.GOAL) and (to.type != TYPE_VERTEX.START or to.type != TYPE_VERTEX.GOAL) and (from.type != to.type):
			Ed += 1
	edges.pop_back()
	edges.pop_front()
	var E: float = edges.size()
	var fe: float = Ed/E
	variation = fe
	return variation

func get_exploration(): #???
	exploration = $Vertices.get_child_count()
	return exploration

func get_weight_duration() -> float:
	var preferred_value = 2
	var sumWeight = 0
	var edges: Array = get_edges()
	for edge in edges:
		sumWeight += edge.weight
	var result: float =  abs(sumWeight - (edges.size() * preferred_value)) / edges.size()
	weightDuration = 1 - result
	return weightDuration

func get_option_replay() -> float:
	var sum_branched_vertex: float = 0.0
	var vertices: Array = get_vertices()
	for vertex in vertices:
		if get_outdegree(vertex) > 1 :
			sum_branched_vertex += 1
	var result: float = sum_branched_vertex / vertices.size()
	optionReplay = result
	return optionReplay

func get_shortest_path() -> int:
	var start: Node = null
	var goal: Node = null
	for vertex in $Vertices.get_children():
		if start == null or goal == null:
			if vertex.type == TYPE_VERTEX.START:
				start = vertex
			if vertex.type == TYPE_VERTEX.GOAL:
				goal = vertex
		else:
			break
	
	var prev: Dictionary = _solve_path(start)
	
	var shortesPath = _reconstruct_path(start, goal, prev)
	shortesPathLength = shortesPath.size()
	return shortesPathLength

func _solve_path(startVertex: Node) -> Dictionary:
	var queue: Array = []
	queue.push_back(startVertex)
	var visitedDict: Dictionary = {}
	var prevDict: Dictionary = {}
	for vertex in $Vertices.get_children():
		visitedDict[vertex.name] = false if vertex.name != startVertex.name else true
		prevDict[vertex.name]= null
	while !queue.empty():
		var vertex = queue.front()
		queue.pop_front()
		var edges: Array = get_outgoing_edges(vertex)
		for edge in edges:
			if !visitedDict[edge.to.name] and edge.type == TYPE_EDGE.PATH:
				queue.push_back(get_vertex(edge.to))
				visitedDict[edge.to.name] = true
				prevDict[edge.to.name] = vertex.name
	return prevDict

func _reconstruct_path(startVertex: Node, goalVertex: Node, prevDict: Dictionary) -> Array:
	var path: Array = []
	var at = goalVertex.name
	while at != null:
		path.append(at)
		at = prevDict[at]
	
	path.invert()
	
	if path[0] == startVertex.name:
		return path
	return []

func get_standard_short_path() -> float:
	var preferred_value = 30
	var shortPathLength: float = get_shortest_path()
	var vertices = get_vertices()
	var shortPathPercentage: float = (shortPathLength / vertices.size()) * 100
	var result: float = 1 - (abs(preferred_value -shortPathPercentage)/preferred_value)
	standardShortPath = result
	return result

func get_fitness() -> float:
	variation = get_variation()
	exploration = get_exploration()
	var weighDuration = get_weight_duration()
	optionReplay = get_option_replay()
	standardShortPath = get_standard_short_path()
	
	var result: float = (variation + weighDuration + optionReplay + standardShortPath)/4
	
	fitness = result
	return fitness

# (2) end ======================================================================

func slide_vertices(inserted_pos: Vector2, direction: Vector2):
	var slideVertices: Array = []
	match direction:
		Vector2.UP:
			for vertex in get_vertices():
				if vertex.position.y <= inserted_pos.y:
					slideVertices.append(vertex)
		Vector2.DOWN:
			for vertex in get_vertices():
				if vertex.position.y >= inserted_pos.y:
					slideVertices.append(vertex)
		Vector2.LEFT:
			for vertex in get_vertices():
				if vertex.position.x <= inserted_pos.x:
					slideVertices.append(vertex)
		Vector2.RIGHT:
			for vertex in get_vertices():
				if vertex.position.x >= inserted_pos.x:
					slideVertices.append(vertex)
	for vertex in slideVertices:
		vertex.position += (direction * cellSize)
	update()

func is_pos_has_placed(_position: Vector2, insertedVertex:Node2D) -> bool:
#	print("check has placed " + str(_position))
	for vertex in get_vertices():
		if vertex != insertedVertex and vertex.position == _position:
#			print("has placed")
			return true
	return false

func is_pos_crossed_line(_position: Vector2, _direction: Vector2) -> bool:
#	print("check crossed_line " + str(_position) + str(_direction))
	for edge in get_edges():
		var direction: Vector2 = edge.from.position.direction_to(edge.to.position)
		#crossing vertical
		if edge.from.position.x == edge.from.position.x and _position.x == edge.from.position.x and _direction.x != 0:
#			print("crossedlinecheck========================")
#			print("_position " + str(_position))
#			print("_direction "+str(_direction))
#			print("direction "+str(direction))
#			print("from position " + str(edge.from.position))
#			print("to position " + str(edge.to.position))
#			print("direction == Vector2.UP " + str(direction == Vector2.UP))
#			print("_position.y <= edge.from.position.y "+ str(_position.y <= edge.from.position.y))
#			print("_position.y >= edge.from.position.y "+str(_position.y >= edge.from.position.y))
#			print("direction == Vector2.DOWN" + str(direction == Vector2.DOWN))
#			print("_position.y >= edge.from.position.y "+str(_position.y >= edge.from.position.y))
#			print("_position.y >= edge.from.position.y "+str(_position.y >= edge.from.position.y))
			if direction == Vector2.UP and _position.y <= edge.from.position.y and _position.y >= edge.to.position.y:
#				print("crossed vertical")
				return true
			elif direction == Vector2.DOWN and _position.y >= edge.from.position.y and _position.y <= edge.to.position.y:
#				print("crossed vertical")
				return true
		#crossing horizontal
		elif edge.from.position.y == edge.from.position.y and _position.y == edge.from.position.y and _direction.y != 0:
#			print("crossedlinecheck========================")
#			print("_position " + str(_position))
#			print("_direction "+str(_direction))
#			print("direction "+str(direction))
#			print("from position " + str(edge.from.position))
#			print("to position " + str(edge.to.position))
#			print("direction == Vector2.LEFT " + str(direction == Vector2.LEFT))
#			print("_position.x <= edge.from.position.x "+ str(_position.x <= edge.from.position.x))
#			print("_position.x >= edge.from.position.x "+str(_position.x >= edge.from.position.x))
#			print("direction == Vector2.RIGHT" + str(direction == Vector2.RIGHT))
#			print("_position.x >= edge.from.position.x "+str(_position.x >= edge.from.position.x))
#			print("_position.x <= edge.from.position.x "+str(_position.x <= edge.from.position.x))
			if direction == Vector2.LEFT and _position.x <= edge.from.position.x and _position.x >= edge.to.position.x:
#				print("crossed horizontal")
				return true
			elif direction == Vector2.RIGHT and _position.x >= edge.from.position.x and _position.x <= edge.to.position.x:
#				print("crossed horizontal")
				return true
	return false

func _draw_dashed_line(from, to, color, width, dash_length = 5, cap_end = false, antialiased = false):
	var length = (to - from).length()
	var normal = (to - from).normalized()
	var dash_step = normal * dash_length
	
	if length < dash_length: #not long enough to dash
		draw_line(from, to, color, width, antialiased)
		return

	else:
		var draw_flag = true
		var segment_start = from
		var steps = length/dash_length
		for start_length in range(0, steps + 1):
			var segment_end = segment_start + dash_step
			if draw_flag:
				draw_line(segment_start, segment_end, color, width, antialiased)

			segment_start = segment_end
			draw_flag = !draw_flag
		
		if cap_end:
			draw_line(segment_start, to, color, width, antialiased)

func _draw():
	#draw tile
	var LINE_COLOR = Color(0.2, 1.0, 0.7, 0.2)
	var LINE_WIDTH = 5
	var gridPoints: PoolVector2Array = []
	for x in range((gridSize.x * 2) + 1):
		var col_pos = (x - gridSize.x) * cellSize.x
		var limit = gridSize.y * cellSize.y
#		draw_line(Vector2(col_pos, 0 - (gridSize.y * cellSize.y)), Vector2(col_pos, limit), LINE_COLOR, LINE_WIDTH)
		gridPoints.append_array([Vector2(col_pos, 0 - (gridSize.y * cellSize.y)), Vector2(col_pos, limit)])
	for y in range((gridSize.y * 2) + 1):
		var row_pos = (y - gridSize.y) * cellSize.y
		var limit = gridSize.x * cellSize.x
#		draw_line(Vector2((0 - gridSize.x * cellSize.x), row_pos), Vector2(limit, row_pos), LINE_COLOR, LINE_WIDTH)
		gridPoints.append_array([Vector2((0 - gridSize.x * cellSize.x), row_pos), Vector2(limit, row_pos)])
	draw_multiline(gridPoints, LINE_COLOR, LINE_WIDTH, true)
	
	#draw edges
	var lines: PoolVector2Array = []
	var linesKl: PoolVector2Array = []
	for edge in get_edges():
		var fromPosition: Vector2 = edge.from.position if  edge.from != null else edge.to.position
		var toPosition: Vector2 = edge.to.position if edge.to != null else edge.from.position
		if edge.type == TYPE_EDGE.PATH:
			# line
			draw_line(fromPosition - Vector2(vertexOuterRadius,0).rotated(fromPosition.angle_to_point(toPosition)), toPosition - Vector2(vertexOuterRadius,0).rotated(toPosition.angle_to_point(fromPosition)), Color.aliceblue, lineSize)
			#arrow left
			draw_line(toPosition - Vector2(vertexOuterRadius,0).rotated(toPosition.angle_to_point(fromPosition)), toPosition - Vector2(vertexOuterRadius + 32,0).rotated(toPosition.angle_to_point(fromPosition) + deg2rad(10)), Color.aliceblue, lineSize)
			#arrow right
			draw_line(toPosition - Vector2(vertexOuterRadius,0).rotated(toPosition.angle_to_point(fromPosition)), toPosition - Vector2(vertexOuterRadius + 32,0).rotated(toPosition.angle_to_point(fromPosition) + deg2rad(-10)), Color.aliceblue, lineSize)
			draw_string(font, (fromPosition + toPosition) / Vector2(2,2), str(edge.weight), Color.aqua)
		if edge.type == TYPE_EDGE.GATE:
			# line
			draw_line(fromPosition - Vector2(vertexOuterRadius,0).rotated(fromPosition.angle_to_point(toPosition)), toPosition - Vector2(vertexOuterRadius,0).rotated(toPosition.angle_to_point(fromPosition)), Color.aliceblue, lineSize)
			#arrow left
			draw_line(toPosition - Vector2(vertexOuterRadius,0).rotated(toPosition.angle_to_point(fromPosition)), toPosition - Vector2(vertexOuterRadius + 32,0).rotated(toPosition.angle_to_point(fromPosition) + deg2rad(10)), Color.aliceblue, lineSize)
			#arrow right
			draw_line(toPosition - Vector2(vertexOuterRadius,0).rotated(toPosition.angle_to_point(fromPosition)), toPosition - Vector2(vertexOuterRadius + 32,0).rotated(toPosition.angle_to_point(fromPosition) + deg2rad(-10)), Color.aliceblue, lineSize)
			#dra crossed line
			draw_line(fromPosition - Vector2(vertexOuterRadius,32).rotated(fromPosition.angle_to_point(toPosition)), fromPosition - Vector2(vertexOuterRadius,-32).rotated(fromPosition.angle_to_point(toPosition)), Color.aliceblue, lineSize)
			draw_string(font, (fromPosition + toPosition) / Vector2(2,2), str(edge.weight), Color.aqua)
		if edge.type == TYPE_EDGE.HIDDEN:
			# dashed line
			var startPoint: Vector2 = fromPosition - Vector2(vertexOuterRadius,0).rotated(fromPosition.angle_to_point(toPosition))
			var endPoint: Vector2 = toPosition - Vector2(vertexOuterRadius,0).rotated(toPosition.angle_to_point(fromPosition))
			_draw_dashed_line(startPoint, endPoint, Color.black, lineSize)
			draw_line(toPosition - Vector2(vertexOuterRadius + 32,0).rotated(toPosition.angle_to_point(fromPosition) + deg2rad(10)), toPosition - Vector2(vertexOuterRadius + 32,0).rotated(toPosition.angle_to_point(fromPosition) + deg2rad(-10)), Color.black, lineSize)
			draw_string(font, (fromPosition + toPosition) / Vector2(2,2), str(edge.weight), Color.aqua)
		if edge.type == TYPE_EDGE.WINDOW:
			# dashed line
			var startPoint: Vector2 = fromPosition - Vector2(vertexOuterRadius,0).rotated(fromPosition.angle_to_point(toPosition))
			var endPoint: Vector2 = toPosition - Vector2(vertexOuterRadius,0).rotated(toPosition.angle_to_point(fromPosition))
			_draw_dashed_line(startPoint, endPoint, Color.darkgray, lineSize)
			draw_string(font, (fromPosition + toPosition) / Vector2(2,2), str(edge.weight), Color.aqua)
		elif edge.type == TYPE_EDGE.KEY_LOCK:
			var direction: Vector2 = fromPosition.direction_to(toPosition)
			var mid: Vector2 = (toPosition + fromPosition)/2
			mid += (Vector2(vertexRadius, vertexRadius) * Vector2(direction.y, direction.x) )
			draw_line(fromPosition - Vector2(0,0).rotated(fromPosition.angle_to_point(toPosition)), mid, Color.aquamarine, lineSize)
			draw_line(mid, toPosition - Vector2(0,0).rotated(toPosition.angle_to_point(fromPosition)), Color.aquamarine, lineSize)
			draw_string(font, mid, str(edge.weight), Color.aqua)
	
	#draw vertices
	for vertex in get_vertices():
		var colorShape: Color = Color.white
		var textSymbol: String = "T"
		var halfNameSize: Vector2 = font.get_string_size(vertex.name)
		#update type
		match vertex.type:
			TYPE_VERTEX.INIT:
				colorShape = Color.white
				textSymbol = "I"
			TYPE_VERTEX.TASK:
				colorShape = Color.white
				textSymbol = "T"
			TYPE_VERTEX.START:
				colorShape = Color.maroon
				textSymbol = "S"
			TYPE_VERTEX.GOAL:
				colorShape = Color.maroon
				textSymbol = "G"
			TYPE_VERTEX.SECRET:
				colorShape = Color.aliceblue
				textSymbol = "St"
			TYPE_VERTEX.OBSTACLE:
				colorShape = Color.red
				textSymbol = "O"
			TYPE_VERTEX.REWARD:
				colorShape = Color.yellow
				textSymbol = "R"
			TYPE_VERTEX.KEY:
				colorShape = Color.greenyellow
				textSymbol = "K"
			TYPE_VERTEX.LOCK:
				colorShape = Color.aqua
				textSymbol = "L"
			TYPE_VERTEX.ENTRANCE:
				colorShape = Color.maroon
				textSymbol = "E"
			TYPE_VERTEX.ROOM:
				colorShape = Color.mediumpurple
				textSymbol = "RM"
			TYPE_VERTEX.CAVE:
				colorShape = Color.purple
				textSymbol = "CA"
			TYPE_VERTEX.CONNECTOR:
				colorShape = Color.whitesmoke
				textSymbol = "CO"
		if vertex.subOf == null:
			draw_circle(vertex.position, vertexRadius, colorShape)
			draw_arc(vertex.position, vertexOuterRadius, 0, PI*2, 50, colorShape, 4)
			draw_string(font, vertex.position + Vector2(-font.get_string_size(textSymbol).x/2, font.get_string_size(textSymbol).x/2), textSymbol, Color.black)
			draw_string(font, vertex.position + Vector2(-halfNameSize.x/2, 0) - Vector2(0,vertexOuterRadius), vertex.name, Color.black)
		else:
			draw_circle(vertex.position, vertexRadius/2, colorShape)
			draw_string(font, vertex.position + Vector2(-font.get_string_size(textSymbol).x/2, font.get_string_size(textSymbol).x/2), textSymbol, Color.black)
#			draw_string(font, vertex.position + Vector2(-halfNameSize.x/2, 0) - Vector2(0,vertexRadius/2), vertex.name, Color.black)

