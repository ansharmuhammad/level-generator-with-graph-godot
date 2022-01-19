extends Rule

func _condition(graph: Node, edge: Node) -> bool:
	if edge.to != "":
		return true
	return false

func _generate(graph: Node, edge: Node):
	var vertex1 = graph.get_vertex_by_name(edge.from)
	var vertex2 = graph.get_vertex_by_name(edge.to)
	
	var vertex3 = graph.add_vertex("", TYPE_VERTEX.TASK)
	var vertex4 = graph.add_vertex("", TYPE_VERTEX.LOCK)
	var vertex5 = graph.add_vertex("", TYPE_VERTEX.KEY)
	var vertex6 = graph.add_vertex("", TYPE_VERTEX.TASK)
	
	edge.init(vertex1.name, vertex3.name)
	graph.connect_vertex(vertex3, vertex4)
	graph.connect_vertex(vertex1, vertex6)
	graph.connect_vertex(vertex6, vertex5)
	graph.connect_vertex(vertex5, vertex3)
	
	graph.connect_vertex(vertex4, vertex2)
	graph.connect_vertex(vertex5, vertex4, TYPE_EDGE.KEY_LOCK)
	
	print("execute rule KL2 at" + str(edge))
