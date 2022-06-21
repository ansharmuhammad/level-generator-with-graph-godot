extends TileMap

#onready var line = $Line2D

var astar  = AStar2D.new()
var usedCell = get_used_cells()

var tileSize = get_cell_size()
var halfTileSize = tileSize/2

var path: PoolVector2Array

#onready var gridSize = 5
#onready var centerGrid = int(gridSize/2)

onready var Generator = get_parent().get_node(".")
onready var drawString = $DrawString

var posCells: Dictionary = {}
var usedPos: Array = []
var room = tile_set.find_tile_by_name("room")

var step: int = 0
var faces: Array

var choosedDirection: Vector2

func _ready():
	pass
#	line.position = line.position + halfTileSize

func _unhandled_input(event):
	if event.is_action_pressed("ui_accept"):
		_execute()

func _execute():
	step += 1
	if step == 1:
		firstStep()
		return
	
	#choose face
	var visitedVertices: Array = posCells.values()
#	var visitedPos: Array = posCells.keys()
	var exploreFace: Array = []
	print("visitedVertices = ",visitedVertices)
	for face in faces:
		#("face = ", face)
		for vertex in face:
			#("vertex = ", vertex)
			if visitedVertices.has(vertex):
				exploreFace = face
				break
		if !exploreFace.empty():
			break
	print("exploreFace = ", exploreFace)
	#if all node in face has placed, remove face
	var unplaceVertex: Array = difference(exploreFace, visitedVertices)
	if unplaceVertex.empty():
		faces.remove(faces.find(exploreFace))
		return
	print("unplaceVertex = ", unplaceVertex)
	
	#assign start and end vertex from face
	var startVertex = null
	var endVertex = null
#	[yyyyynnnyy]
	for i in range(exploreFace.size()):
		if visitedVertices.has(exploreFace[i]) and unplaceVertex.has(exploreFace[i-1]):
			startVertex = exploreFace[i]
		var nextIdx = i + 1
		if nextIdx >= exploreFace.size():
			nextIdx = 0
		if visitedVertices.has(exploreFace[i]) and unplaceVertex.has(exploreFace[nextIdx]):
			endVertex = exploreFace[i]
	print("startVertex = ", startVertex)
	print("endVertex = ", endVertex)
	
	#get space available from star and end vertices
	var startVerticesxPos: Array = getAllPosfromvalue(posCells, startVertex)
	print("startVerticesxPos = ",startVerticesxPos)
	var endVerticesPos: Array = getAllPosfromvalue(posCells, endVertex)
	print("endVerticesPos = ",endVerticesPos)
	var startVertexSpaceAvail: Array = getSpacePosFromVertices(startVerticesxPos)
	print("startVertexSpaceAvail = ",startVertexSpaceAvail)
	var endVertexpSaceAvail: Array = getSpacePosFromVertices(endVerticesPos)
	print("endVertexpSaceAvail = ",endVertexpSaceAvail)
	
	#get shortes distance from combination start and end point available
	var shortestDist = 1000
	var startPoint: Vector2
	var endPoint: Vector2
#	var arrOfDictCombPoint: Array = []
	usedPos = keysofVec(posCells)
	for startVertexSpace in startVertexSpaceAvail:
		for endVertexpSace in endVertexpSaceAvail:
			var cellBetweenPoint = filterUsedPosBetween2point(usedPos,startVertexSpace,endVertexpSace)
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
	
	var pathConnector: Array = getPathConnector(startPoint, endPoint, unplaceVertex)
	
	print("pathConnector = ", pathConnector)
#	pathConnector.append_array([Vector2(5,5),line.position])
	
	placeCell(pathConnector, unplaceVertex)
	
	for i in range(pathConnector.size()):
		pathConnector[i] = map_to_world(pathConnector[i])
	
	var Line2d = Line2D
	var line = Line2d.new()
	add_child(line)
	line.position = Vector2.ZERO + halfTileSize
	line.width = 5
	line.set_default_color(Color( randf(), randf(), randf(), 0.6 ))
	line.points = pathConnector
	
	faces.erase(exploreFace)

func firstStep():
	var initPos = 5
	faces = Generator.faces
	var initVertex = faces[0]
	#("faces[0] = ", faces[0])
	initVertex = initVertex[0]
	#("initVertex = ", initVertex)
	set_cell(initPos, initPos, room)
	posCells[vect2str(Vector2(initPos,initPos))] = initVertex
	drawString.update()

func vect2str(vector: Vector2) -> String:
	return "(" + str(vector.x) + ", " + str(vector.y) + ")"

func str2vec(string: String) -> Vector2:
	return str2var("Vector2" + string)

func keysofVec(dictionaryVec: Dictionary) -> Array:
	var pos: Array = []
	for vec in dictionaryVec.keys():
		pos.append(str2vec(vec))
	return pos

func filterUsedPosBetween2point(arrayPos: Array, point1: Vector2, point2: Vector2) -> Array:
	var result: Array = []
	var minVect: Vector2 = Vector2(min(point1.x, point2.x), min(point1.y, point2.y))
	var maxVect: Vector2 = Vector2(max(point1.x, point2.x), max(point1.y, point2.y))
	for vector in arrayPos:
		if vector.x > minVect.x and vector.x < maxVect.x and vector.y > minVect.y and vector.y < maxVect.y:
			result.append(vector)
	return result

func countCellOnDirectionWith2Point(arrayPos: Array, point1: Vector2, point2: Vector2, direction: Vector2) -> int:
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

func difference(arr1, arr2):
	var only_in_arr1 = []
	for v in arr1:
		if not (v in arr2):
			only_in_arr1.append(v)
	return only_in_arr1

func sameValue(array1: Array, array2: Array) -> Array:
	var sameValue = []
	for v in array1:
		if (v in array2):
			sameValue.append(v)
	return sameValue

func shareValue(array1: Array, array2: Array) -> bool:
	for i in array1:
		for o in array2:
			if i == o:
				return true
	return false

func getKeysofValue(dictionary : Dictionary, value) -> Array:
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

func getAllPosfromvalue(dictionary: Dictionary, value: String) -> Array:
	var keys: Array = getKeysofValue(dictionary, value)
	var allPos: Array = []
	for key in keys:
		allPos.append(str2vec(key))
	return allPos

func getSpacePosFromVertices(verticesPos: Array) -> Array:
	var spcaeAvail: Array = []
	var usedCells = get_used_cells()
	var neighbors: Array = [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]
	for neighbor in neighbors:
		for pos in verticesPos:
			var currentPos: Vector2 = pos + neighbor
			if !spcaeAvail.has(currentPos) and !usedCells.has(currentPos):
				spcaeAvail.append(currentPos)
	return spcaeAvail

func getStraightPath(point1: Vector2, point2: Vector2) -> Array:
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

func getPathConnector(startPoint: Vector2, endPoint: Vector2, unplaceVertex: Array) -> Array:
	#get intersect point
	var intersectPoint = [Vector2(startPoint.x, endPoint.y), Vector2(endPoint.x, startPoint.y)]
	for point in intersectPoint:
		#("candidatepoint = ", point)
		#("usedCell.has ", usedPos.has(point))
		if usedPos.has(point):
			intersectPoint.erase(point)
	intersectPoint = intersectPoint[randi() % intersectPoint.size()]
	print("intersectPoint = ",intersectPoint)
	
	#get path connector
	var pathConnector: Array = []
	#("start = ", intersectPoint, " to = ", startPoint)
	if !getStraightPath(intersectPoint, startPoint).empty():
		pathConnector.append_array(getStraightPath(intersectPoint, startPoint))
		#("pathConnector = ", pathConnector)
	pathConnector.append(intersectPoint)
	#("start = ", intersectPoint, " to = ", endPoint)
	if !getStraightPath(intersectPoint, endPoint).empty():
		pathConnector.append_array(getStraightPath(intersectPoint, endPoint))
		#("pathConnector = ", pathConnector)
	
	var canItPlaced: bool = !shareValue(unplaceVertex, posCells.values()) and pathConnector.size() > unplaceVertex.size()
	
	#get safe direction
	if !canItPlaced:
		var directionsCheck: Array = [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]
		var startPointDirectionAvail: Array = []
		var endPointDirectionAvail: Array = []
		print("used pos ", usedPos)
		for direction in directionsCheck:
			var startAvailPoint = startPoint + direction
			if !usedPos.has(startAvailPoint) and startAvailPoint != endPoint:
				#("startAvailPoint ", startAvailPoint)
				startPointDirectionAvail.append(direction)
			var endAvailPoint = endPoint + direction
			if !usedPos.has(endAvailPoint) and endAvailPoint != startPoint:
				#("endAvailPoint ", endAvailPoint)
				endPointDirectionAvail.append(direction)
		
		var directions: Array = sameValue(startPointDirectionAvail, endPointDirectionAvail)
		directions.shuffle()
#		choosedDirection
		var dirWeght:int = 1000
		for direction in directions:
			if countCellOnDirectionWith2Point(usedPos, startPoint, endPoint, direction) < dirWeght:
				choosedDirection = direction
		print("choosedDirection", choosedDirection)
		while !canItPlaced:
			extendPath(pathConnector, choosedDirection, startPoint, endPoint)
			canItPlaced = !shareValue(unplaceVertex, posCells.values()) and pathConnector.size() > unplaceVertex.size()
		
	return pathConnector

func extendPath(path: Array, direction: Vector2, startPoint: Vector2, endPoint: Vector2):
	for i in (path.size()):
		path[i] = path[i] + direction
	
	path.push_front(startPoint)
	path.push_back(endPoint)

func placeCell(path: Array, unplaceVertex: Array):
	#("path.size() ",path.size())
	#("unplaceVertex.size() ", unplaceVertex.size())
	for i in range(path.size()):
		var vertex = unplaceVertex[i] if i < (unplaceVertex.size()-1) else unplaceVertex[-1]
		var point = path[i]
		set_cell(point.x, point.y, room)
		#("placing at ",Vector2(point.x,point.y))
		posCells[vect2str(Vector2(point.x,point.y))] = vertex
	drawString.update()
