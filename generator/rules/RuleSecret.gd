extends Rule

func _condition(graph: Node, edge: Node) -> bool:
	var from = graph.get_vertex_by_name(edge.from)
	var to = graph.get_vertex_by_name(edge.to)
	if (from.type == TYPE_VERTEX.TASK or to.type == TYPE_VERTEX.TASK) and edge.type == TYPE_EDGE.PATH:
		return true
	return false

func _generate(graph: Node, edge: Node):
	var from = graph.get_vertex_by_name(edge.from)
	var to = graph.get_vertex_by_name(edge.to)
	
	var arrayVertex: Array = []
	if from.type == TYPE_VERTEX.TASK:
		arrayVertex.append(from)
	if to.type == TYPE_VERTEX.TASK:
		arrayVertex.append(to)
	randomize()
	
	var vertex1 = arrayVertex[randi() % arrayVertex.size()]
	var vertex2 = graph.add_vertex("",TYPE_VERTEX.SECRET)
	
	graph.connect_vertex(vertex1, vertex2)
	
	#("execute rule Secret at" + str(edge) + "detail : " + vertex1.name)
