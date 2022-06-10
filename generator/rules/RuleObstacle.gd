extends Rule

func _condition(graph: Node, edge: Node) -> bool:
	if edge.to != "":
		return true
	return false

func _generate(graph: Node, edge: Node):
	print("execute rule Obstacle at" + str(edge))
	var vertex1 = graph.get_vertex_by_name(edge.from)
	var vertex2 = graph.get_vertex_by_name(edge.to)
	var vertex3 = graph.add_vertex("", TYPE_VERTEX.OBSTACLE)
	
	edge.init(vertex1.name, vertex3.name)
	graph.connect_vertex(vertex3, vertex2)
	
