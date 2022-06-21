extends TileMap

onready var Generator: Node = get_parent().get_node(".")
onready var drawString: Node = $DrawString
var faces: Array

var tileSize = get_cell_size()
var halfTileSize = tileSize/2
var room = tile_set.find_tile_by_name("room")

var step: int = 0
var executedFace: Array = []

var posCells: Dictionary = {}
var choosedDirection: Vector2

func _ready():
	pass

func _unhandled_input(event):
	if event.is_action_pressed("ui_accept"):
		step += 1
		if step == 1:
			firstStep()
		elif !faces.empty():
			_execute()

func firstStep():
	var initPos = 15
	faces = Generator.faces.duplicate()
	var initVertex = faces[0]
	#("faces[0] = ", faces[0])
	initVertex = initVertex[0]
	#("initVertex = ", initVertex)
	set_cell(initPos, initPos, room)
	posCells[_vect2str(Vector2(initPos,initPos))] = initVertex
	drawString.update()

func _execute():
	#get all visited vertices on face
	var visitedVertices: Array = posCells.values()
	
	#update executed face
	_update_executed_face(visitedVertices)
	
	#get unvisited vertices on face
	var unvisitedVerticesonFace: Array = _get_unvisited_vertices_on_face(visitedVertices)
	print("unvisitedVerticesonFace = ", unvisitedVerticesonFace)
	
	#if all node in face has placed, remove face and go to next iteration
	if unvisitedVerticesonFace.empty():
		faces.erase(executedFace)
		executedFace.clear()
		return
	
	#get start and end vertex
	var vertex: Dictionary = _get_start_and_end_vertex(visitedVertices, unvisitedVerticesonFace)
	
	#get vertices will placed
	var verticesWillPlaced: Array = []
	var startCycle: int = executedFace.find(vertex["start"])
	var endCycle: int = executedFace.find(vertex["end"])
	while executedFace[startCycle-1] != executedFace[endCycle]:
		startCycle -= 1
		if executedFace[startCycle] != executedFace[endCycle]:
			verticesWillPlaced.append(executedFace[startCycle])
	
	print("verticesWillPlaced = ", verticesWillPlaced)
	
	#get start and end point to place unvisited vertex
	var point: Dictionary = _get_start_and_end_point(vertex["start"], vertex["end"])
	
	#get path connector from start to end point
	var pathConnector: Array = _get_path_connector(point["start"], point["end"], verticesWillPlaced, choosedDirection)
	print("pathConnector = ", pathConnector)
	
	_place_cell(pathConnector, verticesWillPlaced)
	
	for i in range(pathConnector.size()):
		pathConnector[i] = map_to_world(pathConnector[i])
	
	_addLine(pathConnector)
	
	if _difference(executedFace, posCells.values()).empty():
		executedFace.clear()

func _vect2str(vector: Vector2) -> String:
	return "(" + str(vector.x) + ", " + str(vector.y) + ")"

func _str2vec(string: String) -> Vector2:
	return str2var("Vector2" + string)

func _keysofVec(dictionaryVec: Dictionary) -> Array:
	var pos: Array = []
	for vec in dictionaryVec.keys():
		pos.append(_str2vec(vec))
	return pos

func _difference(arr1, arr2):
	var only_in_arr1 = []
	for v in arr1:
		if not (v in arr2):
			only_in_arr1.append(v)
	return only_in_arr1

func _same_value(array1: Array, array2: Array) -> Array:
	var sameValue = []
	for v in array1:
		if (v in array2):
			sameValue.append(v)
	return sameValue

func _share_value(array1: Array, array2: Array) -> bool:
	for i in array1:
		for o in array2:
			if i == o:
				return true
	return false

func _update_executed_face(visitedVertices: Array):
	print("visitedVertices = ",visitedVertices)
	if executedFace.empty():
		for face in faces:
			if _share_value(visitedVertices, face):
				executedFace = face
				print("executedFace = ", executedFace)
				return

func _get_unvisited_vertices_on_face(visitedVertices: Array) -> Array:
	print("executedFace = ", executedFace)
	return _difference(executedFace, visitedVertices)

func _get_start_and_end_vertex(visitedVertices: Array, unvisitedVerticesOnFace: Array) -> Dictionary:
	var startVertex = null
	var endVertex = null
#	[yyyyynnnyy]
	for i in range(executedFace.size()):
		var nextIdx = i + 1
		if nextIdx >= executedFace.size():
			nextIdx = 0
		if visitedVertices.has(executedFace[i]) and unvisitedVerticesOnFace.has(executedFace[nextIdx]):
			endVertex = executedFace[i]
		
		if visitedVertices.has(executedFace[i]) and unvisitedVerticesOnFace.has(executedFace[i-1]):
			startVertex = executedFace[i]
	
	print("startVertex = ", startVertex)
	print("endVertex = ", endVertex)
	var vertex = { 
		"start": startVertex,
		"end": endVertex
	}
	return vertex

func _get_start_and_end_point(startVertex: String, endVertex: String) -> Dictionary:
	#get space availabe around start and end vertex
	var spaceAvail: Dictionary = {
		"start" : _get_sapce_availabel(startVertex),
		"end" : _get_sapce_availabel(endVertex)
	}
	
	var shortestDist = 1000
	var startPoint: Vector2
	var endPoint: Vector2
#	var arrOfDictCombPoint: Array = []
#	var usedPos = _keysofVec(posCells)
	for startVertexSpace in spaceAvail["start"]:
		for endVertexpSace in spaceAvail["end"]:
			var cellBetweenPoint = _filter_used_pos_between_2point(get_used_cells(),startVertexSpace,endVertexpSace)
			#("cellBetweenPoint ",startVertexSpace," ",endVertexpSace," = ",cellBetweenPoint)
			var tempDist = startVertexSpace.distance_squared_to(endVertexpSace) + cellBetweenPoint.size()
			#("tempDist = ",tempDist)
			if tempDist < shortestDist and startVertexSpace != endVertexpSace:
				shortestDist = tempDist
				startPoint = startVertexSpace
				endPoint = endVertexpSace
			elif tempDist == shortestDist and startVertexSpace != endVertexpSace:
				var percent = randf()
				if (percent > 0.5):
					shortestDist = tempDist
					startPoint = startVertexSpace
					endPoint = endVertexpSace
	print("startPoint = ",startPoint)
	print("endPoint = ",endPoint)
	
	var directionsCheck: Array = [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]
	var startPointDirectionAvail: Array = []
	var endPointDirectionAvail: Array = []
	print("used pos ", get_used_cells())
	for direction in directionsCheck:
		var startAvailPoint = startPoint + direction
		if !get_used_cells().has(startAvailPoint) and startAvailPoint != endPoint:
			#("startAvailPoint ", startAvailPoint)
			startPointDirectionAvail.append(direction)
		var endAvailPoint = endPoint + direction
		if !get_used_cells().has(endAvailPoint) and endAvailPoint != startPoint:
			#("endAvailPoint ", endAvailPoint)
			endPointDirectionAvail.append(direction)
	
	var directions: Array = _same_value(startPointDirectionAvail, endPointDirectionAvail)
	directions.shuffle()
	
	var dirWeght:int = 1000
	for direction in directions:
		if _count_cell_on_direction_with_2Point(get_used_cells(), startPoint, endPoint, direction) < dirWeght:
			choosedDirection = direction
	print("choosedDirection", choosedDirection)
	
	var rekursifResult: Dictionary
	var resultGraph = Generator.get_node("Result/GrapResult")
	var startVertexConnectionUnplace = _difference(resultGraph.get_neighbors_name_by_name(startVertex), posCells.values()).size()
	var endVertexConnectionUnplace = _difference(resultGraph.get_neighbors_name_by_name(endVertex), posCells.values()).size()
	print("connStart ",startVertexConnectionUnplace," vs avail ",spaceAvail["start"].size())
	print("connEnd ",endVertexConnectionUnplace," vs avail ",spaceAvail["end"].size())
	if startVertexConnectionUnplace > spaceAvail["start"].size():
		print("extend start")
		set_cellv(startPoint, room)
		posCells[_vect2str(startPoint)] = startVertex
		rekursifResult = _get_start_and_end_point(startVertex, endVertex)
		return rekursifResult
	elif endVertex != startVertex and endVertexConnectionUnplace > spaceAvail["end"].size():
		print("extend end")
		set_cellv(endPoint, room)
		posCells[_vect2str(endPoint)] = endVertex
		rekursifResult = _get_start_and_end_point(startVertex, endVertex)
		return rekursifResult
	
	var point: Dictionary = {
		"start": startPoint,
		"end": endPoint
	}
	
	return point

func _get_sapce_availabel(vertex: String) -> Array:
	var keys: Array = _get_keys_of_value(posCells, vertex)
	var allPos: Array = []
	for key in keys:
		allPos.append(_str2vec(key))
	
	var spcaeAvail: Array = []
	var usedCells = get_used_cells()
	var neighbors: Array = [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]
	for neighbor in neighbors:
		for pos in allPos:
			var currentPos: Vector2 = pos + neighbor
			if !spcaeAvail.has(currentPos) and !usedCells.has(currentPos):
				spcaeAvail.append(currentPos)
	return spcaeAvail

func _filter_used_pos_between_2point(arrayPos: Array, point1: Vector2, point2: Vector2) -> Array:
	var result: Array = []
	var minVect: Vector2 = Vector2(min(point1.x, point2.x), min(point1.y, point2.y))
	var maxVect: Vector2 = Vector2(max(point1.x, point2.x), max(point1.y, point2.y))
	for vector in arrayPos:
		if vector.x > minVect.x and vector.x < maxVect.x and vector.y > minVect.y and vector.y < maxVect.y:
			result.append(vector)
	return result

func _get_keys_of_value(dictionary : Dictionary, value) -> Array:
	var indice: Array = []
	var values: Array = dictionary.values()
	#("dictionary ", dictionary)
	#("value ", value, "; values ", values)
	for i in range(values.size()):
		if value == values[i]:
			indice.append(i)
	
	var result: Array = []
	var keys: Array = dictionary.keys()
	for index in indice:
		result.append(keys[index])
	
	return result

func _count_cell_on_direction_with_2Point(arrayPos: Array, point1: Vector2, point2: Vector2, direction: Vector2) -> int:
	var result: Array = []
	match direction:
		Vector2.UP:
			for vector in arrayPos:
				if vector.y < point1.y or vector.y < point2.y:
					result.append(vector)
		Vector2.DOWN:
			for vector in arrayPos:
				if vector.y > point1.y or vector.y > point2.y:
					result.append(vector)
		Vector2.LEFT:
			for vector in arrayPos:
				if vector.x < point1.x or vector.x < point2.x:
					result.append(vector)
		Vector2.RIGHT:
			for vector in arrayPos:
				if vector.x > point1.x or vector.x > point2.x:
					result.append(vector)
	return result.size()

func _get_path_connector(startPoint: Vector2, endPoint: Vector2, unplaceVertex: Array, choosedDirection: Vector2) -> Array:
#	var usedPos = _keysofVec(posCells)
	
	#get intersect point
	var intersectPoint = [Vector2(startPoint.x, endPoint.y), Vector2(endPoint.x, startPoint.y)]
	for point in intersectPoint:
		#("candidatepoint = ", point)
		#("usedCell.has ", usedPos.has(point))
		if get_used_cells().has(point):
			intersectPoint.erase(point)
	intersectPoint = intersectPoint[randi() % intersectPoint.size()]
	print("intersectPoint = ",intersectPoint)
	
	#get path connector
	var pathConnector: Array = []
	#("start = ", intersectPoint, " to = ", startPoint)
	if !_get_straight_path(intersectPoint, startPoint).empty():
		pathConnector.append_array(_get_straight_path(intersectPoint, startPoint))
		#("pathConnector = ", pathConnector)
	pathConnector.append(intersectPoint)
	#("start = ", intersectPoint, " to = ", endPoint)
	if !_get_straight_path(intersectPoint, endPoint).empty():
		pathConnector.append_array(_get_straight_path(intersectPoint, endPoint))
		#("pathConnector = ", pathConnector)
	
#	var canItPlaced: bool = !_share_value(unplaceVertex, posCells.values()) and pathConnector.size() >= unplaceVertex.size()
	var canItPlaced: bool = !_share_value(pathConnector, get_used_cells()) and pathConnector.size() >= unplaceVertex.size()
	
	#get safe direction
#	if !canItPlaced:
	if !canItPlaced:
		var directionsCheck: Array = [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]
		var startPointDirectionAvail: Array = []
		var endPointDirectionAvail: Array = []
#		print("used pos ", get_used_cells())
		for direction in directionsCheck:
			var startAvailPoint = startPoint + direction
			if !get_used_cells().has(startAvailPoint) and startAvailPoint != endPoint:
				#("startAvailPoint ", startAvailPoint)
				startPointDirectionAvail.append(direction)
			var endAvailPoint = endPoint + direction
			if !get_used_cells().has(endAvailPoint) and endAvailPoint != startPoint:
				#("endAvailPoint ", endAvailPoint)
				endPointDirectionAvail.append(direction)
		
		var directions: Array = _same_value(startPointDirectionAvail, endPointDirectionAvail)
		directions.shuffle()
#		choosedDirection
		var dirWeght:int = 1000
		for direction in directions:
			if _count_cell_on_direction_with_2Point(get_used_cells(), startPoint, endPoint, direction) < dirWeght:
				choosedDirection = direction
		print("choosedDirection", choosedDirection)
		while !canItPlaced:
			_extend_path(pathConnector, choosedDirection, startPoint, endPoint)
			canItPlaced = !_share_value(pathConnector, get_used_cells()) and pathConnector.size() >= unplaceVertex.size()
		
	return pathConnector

func _get_straight_path(point1: Vector2, point2: Vector2) -> Array:
	var result: Array = []
	if point1 == point2:
		return []
	var isHorizontal: bool = true if point1.x != point2.x else false
	if isHorizontal:
		var ispositif:int = 1 if point1.x < point2.x else -1
		for i in range(abs(point1.x - point2.x)):
			point1.x += (1 * ispositif)
			result.append(point1)
	else:
		var ispositif:int = 1 if point1.y < point2.y else -1
		for i in range(abs(point1.y - point2.y)):
			point1.y += (1 * ispositif)
			result.append(point1)
	return result

func _extend_path(path: Array, direction: Vector2, startPoint: Vector2, endPoint: Vector2):
	for i in (path.size()):
		path[i] = path[i] + direction
	
	path.push_front(startPoint)
	path.push_back(endPoint)

func _place_cell(path: Array, unplaceVertex: Array):
	#("path.size() ",path.size())
	#("unplaceVertex.size() ", unplaceVertex.size())
	for i in range(path.size()):
		var vertex = unplaceVertex[i] if i < (unplaceVertex.size()-1) else unplaceVertex[-1]
		var point = path[i]
		set_cell(point.x, point.y, room)
		#("placing at ",Vector2(point.x,point.y))
		posCells[_vect2str(Vector2(point.x,point.y))] = vertex
	drawString.update()

func _addLine(path: Array):
	var Line2d = Line2D
	var line = Line2d.new()
	add_child(line)
	line.position = Vector2.ZERO + halfTileSize
	line.width = 5
	line.set_default_color(Color( randf(), randf(), randf(), 0.6 ))
	line.points = path
