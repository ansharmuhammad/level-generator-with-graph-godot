class_name Rule
extends Node

func execute(graph: Node):
	var match_edge: Array = []
	for edge in graph.get_node("Edges").get_children():
		if _condition(graph, edge):
			match_edge.append(edge)
	if match_edge.size() > 0:
		randomize()
		var chosenEdge = match_edge[randi() % match_edge.size()]
		_generate(graph, chosenEdge)

func _condition(graph: Node, edge: Node) -> bool:
	return false

func _generate(graph: Node, edge: Node):
	pass
