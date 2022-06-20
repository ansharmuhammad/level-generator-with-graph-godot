extends Rule

func _condition(graph: Node, edge: Node) -> bool:
	var from = graph.get_vertex_by_name(edge.from)
	var to = graph.get_vertex_by_name(edge.to)
	if graph.is_place(from) and graph.is_place(to):
		return true
	return false

func _generate(graph: Node, edge: Node):
	#("execute rule KL3 at" + str(edge))
	var vertex1 = graph.get_vertex_by_name(edge.from)
	var vertex2 = graph.get_vertex_by_name(edge.to)
	
	var vertex3 = graph.add_vertex("", TYPE_VERTEX.TASK)
	var vertex4 = graph.add_vertex("", TYPE_VERTEX.LOCK)
	var vertex5 = graph.add_vertex("", TYPE_VERTEX.TASK)
	var vertex6 = graph.add_vertex("", TYPE_VERTEX.KEY)
	
	edge.init(vertex1.name, vertex3.name)
	graph.connect_vertex(vertex3, vertex4)
	graph.connect_vertex(vertex3, vertex5)
	graph.connect_vertex(vertex5, vertex6)
	graph.connect_vertex(vertex6, vertex1)
	
	graph.connect_vertex(vertex4, vertex2)
	graph.connect_vertex(vertex6, vertex4, TYPE_EDGE.KEY_LOCK)
	
