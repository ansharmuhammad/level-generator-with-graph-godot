extends TileMap

onready var line = $Line2D

var astar  = AStar2D.new()
var usedCell = get_used_cells()

var tileSize = get_cell_size()
var halfTileSize = tileSize/2

var path: PoolVector2Array

#onready var gridSize = 5
#onready var centerGrid = int(gridSize/2)

onready var Generator = get_parent().get_node(".")

var posCells = {}
var room = tile_set.find_tile_by_name("room")

var step: int = 0
var faces

func _ready():
	pass

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
		print("face = ", face)
		for vertex in face:
			print("vertex = ", vertex)
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
	var usedPos: Array = keysofVec(posCells)
	for startVertexSpace in startVertexSpaceAvail:
		for endVertexpSace in endVertexpSaceAvail:
			var cellBetweenPoint = filterUsedPosBetween2point(usedPos,startVertexSpace,endVertexpSace)
			print("cellBetweenPoint ",startVertexSpace," ",endVertexpSace," = ",cellBetweenPoint)
			var tempDist = startVertexSpace.distance_squared_to(endVertexpSace) + cellBetweenPoint.size()
			print("tempDist = ",tempDist)
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
	
	#get intersect point
	var intersectPoint = [Vector2(startPoint.x, endPoint.y), Vector2(endPoint.x, startPoint.y)]
	for point in intersectPoint:
		print("candidatepoint = ", point)
		print("usedCell.has ", usedPos.has(point))
		if usedPos.has(point):
			intersectPoint.erase(point)
	intersectPoint = intersectPoint[randi() % intersectPoint.size()]
	print("intersectPoint = ",intersectPoint)
	
	#get path connector
	var pathConnector: Array = []
	print("start = ", intersectPoint, " to = ", startPoint)
	if !getStraightPath(intersectPoint, startPoint).empty():
		pathConnector.append_array(getStraightPath(intersectPoint, startPoint))
		print("pathConnector = ", pathConnector)
	pathConnector.append(intersectPoint)
	print("start = ", intersectPoint, " to = ", endPoint)
	if !getStraightPath(intersectPoint, endPoint).empty():
		pathConnector.append_array(getStraightPath(intersectPoint, endPoint))
		print("pathConnector = ", pathConnector)
	
	print("pathConnector = ", pathConnector)
#	pathConnector.append_array([Vector2(5,5),line.position])
	line.position = line.position + halfTileSize
	placeCell(pathConnector, unplaceVertex)
	for i in range(pathConnector.size()):
		pathConnector[i] = map_to_world(pathConnector[i])
	line.points = pathConnector

func firstStep():
	var initPos = 5
	faces = Generator.faces
	var initVertex = faces[0]
	print("faces[0] = ", faces[0])
	initVertex = initVertex[0]
	print("initVertex = ", initVertex)
	set_cell(initPos, initPos, room)
	posCells[vect2str(Vector2(initPos,initPos))] = initVertex

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

func difference(arr1, arr2):
	var only_in_arr1 = []
	for v in arr1:
		if not (v in arr2):
			only_in_arr1.append(v)
	return only_in_arr1

func getKeysofValue(dictionary : Dictionary, value) -> Array:
	var indice: Array = []
	var values: Array = dictionary.values()
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

func placeCell(path: Array, unplaceVertex: Array):
	print("path.size() ",path.size())
	print("unplaceVertex.size() ", unplaceVertex.size())
	if path.size() < unplaceVertex.size():
		return false
	for i in range(path.size()):
		var vertex = unplaceVertex if i < (unplaceVertex.size()-1) else unplaceVertex[-1]
		var point = path[i]
		set_cell(point.x, point.y, room)
		print("placing at ",Vector2(point.x,point.y))
		posCells[vect2str(Vector2(point.x,point.y))] = vertex
#func _get_path(start, end):
#	path = astar.get_point_path(id(start), id(end))
#	var linePath = []
#	for point in path:
#		linePath.append(map_to_world(point))
#	line.position = astar.get_point_position(id(start)) + halfTileSize
#	line.points = linePath
