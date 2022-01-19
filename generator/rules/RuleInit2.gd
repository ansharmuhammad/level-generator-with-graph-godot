extends Rule

func _condition(graph: Node, edge: Node) -> bool:
	var from = graph.get_vertex_by_name(edge.from)
	if from.type == TYPE_VERTEX.INIT and edge.to == "":
		return true
	return false

func _generate(graph: Node, edge: Node):
	var vertex1 = graph.get_vertex_by_name(edge.from)
	vertex1.type = TYPE_VERTEX.START
	
	var vertex2 = graph.add_vertex()
	var vertex3 = graph.add_vertex()
	var vertex4 = graph.add_vertex()
	var vertex5 = graph.add_vertex("",TYPE_VERTEX.GOAL)
	var vertex6 = graph.add_vertex()
	
	edge.init(vertex1.name, vertex2.name)
	graph.connect_vertex(vertex2, vertex3)
	graph.connect_vertex(vertex3, vertex4)
	graph.connect_vertex(vertex4, vertex5)
	graph.connect_vertex(vertex4, vertex6)
	graph.connect_vertex(vertex6, vertex2)
	
	print("execute rule init2 at" + str(edge))
