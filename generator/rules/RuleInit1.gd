extends Rule

func _condition(graph: Node, edge: Node) -> bool:
	var from = graph.get_vertex_by_name(edge.from)
	if from.type == TYPE_VERTEX.INIT and edge.to == "":
		return true
	return false

func _generate(graph: Node, edge: Node):
	print("execute rule init1 at" + str(edge))
	var vertex1 = graph.get_vertex_by_name(edge.from)
	vertex1.type = TYPE_VERTEX.START
	
	var vertex2 = graph.add_vertex()
	var vertex3 = graph.add_vertex("",TYPE_VERTEX.GOAL)
	var vertex4 = graph.add_vertex()
	
	edge.init(vertex1.name, vertex2.name)
	graph.connect_vertex(vertex2, vertex3)
	graph.connect_vertex(vertex3, vertex4)
	graph.connect_vertex(vertex4, vertex1)
