extends Rule

func _condition(graph: Node, edge: Node) -> bool:
	if edge.type == TYPE_EDGE.PATH:
		return true
	return false

func _generate(graph: Node, edge: Node):
	var vertex1 = graph.get_vertex_by_name(edge.from)
	var vertex2 = graph.get_vertex_by_name(edge.to)
	var vertex3 = graph.add_vertex()
	var vertex4 = graph.add_vertex()
	
	graph.connect_vertex(vertex1, vertex4)
	graph.connect_vertex(vertex4, vertex3)
	graph.connect_vertex(vertex3, vertex2)
	
	print("execute rule Extend2 at" + str(edge))
