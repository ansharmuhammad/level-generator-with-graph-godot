extends Rule

func _condition(graph: Node, edge: Node) -> bool:
	if edge.type == TYPE_EDGE.PATH:
		return true
	return false

func _generate(graph: Node, edge: Node):
	var vertex1 = graph.get_vertex_by_name(edge.from)
	var vertex2 = graph.get_vertex_by_name(edge.to)
	var vertex3 = graph.add_vertex()
	
	edge.init(vertex1.name, vertex3.name)
	graph.connect_vertex(vertex3, vertex2)
	
	print("execute rule Extend1 at" + str(edge))
