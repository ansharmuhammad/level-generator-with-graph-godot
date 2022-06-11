extends Node2D

onready var file: File = File.new()

func _ready():
	file.open("res://generator/loggen.txt", File.WRITE)
	file.store_line("==============================================================================")
	file.close()

func to_dot(graph: Node, label: String = ""):
#	file.open("res://generator/loggen.txt", File.READ_WRITE)
	file.open("res://generator/loggen.txt", File.READ_WRITE)
	file.seek_end()
	file.store_line("digraph G {")
	file.store_line('labelloc="t"')
	file.store_line('label="' + label + '"')
	file.store_line('node [shape="circle" style=filled colorscheme=pastel19]')
	file.store_line('edge [colorscheme=dark28 color=8]')
	for edge in graph.get_edges():
		var vertex1: Node = graph.get_vertex_by_name(edge.from)
		var vertex2: Node = graph.get_vertex_by_name(edge.to)
		if (vertex1 != null and vertex2 != null) and (vertex1.subOf == null and vertex2.subOf == null):
#		if (vertex1 != null and vertex2 != null) and (vertex1.subOf == null and vertex2.subOf == null) and (edge.type == TYPE_EDGE.PATH) :
			if !graph.is_element(vertex1) and edge.type == TYPE_EDGE.PATH:
				file.store_line('"'+vertex_dot(vertex1)+'"' + " -> " + '"'+vertex_dot(vertex2)+'"'+' [label = "'+str(edge.weight)+'"]')
			elif edge.type == TYPE_EDGE.KEY_LOCK:
				file.store_line('"'+vertex_dot(vertex1)+'"' + " -> " + '"'+vertex_dot(vertex2)+'" [ style=dashed color=5 ]'+' [label = "'+str(edge.weight)+'"]')
			if graph.is_element(vertex1) and edge.type != TYPE_EDGE.KEY_LOCK:
				file.store_line('"'+vertex_dot(vertex1)+'"' + " -> " + '"'+vertex_dot(vertex2)+'"'+' [ color=6 label = "'+str(edge.weight)+'"]')
	for vertex in graph.get_vertices():
		if vertex.type == TYPE_VERTEX.START and vertex.subOf == null:
			file.store_line('"'+vertex_dot(vertex)+'"' + " [peripheries=2]")
		if vertex.type == TYPE_VERTEX.GOAL and vertex.subOf == null:
			file.store_line('"'+vertex_dot(vertex)+'"' + " [peripheries=2]")
		if vertex.type == TYPE_VERTEX.REWARD and vertex.subOf == null:
			file.store_line('"'+vertex_dot(vertex)+'"' + " [fillcolor=6]")
		if vertex.type == TYPE_VERTEX.OBSTACLE and vertex.subOf == null:
			file.store_line('"'+vertex_dot(vertex)+'"' + " [fillcolor=1]")
		if (vertex.type == TYPE_VERTEX.KEY or vertex.type == TYPE_VERTEX.LOCK) and vertex.subOf == null:
			file.store_line('"'+vertex_dot(vertex)+'"' + " [fillcolor=3]")
	file.store_line("}")
	file.store_line("==============================================================================")
	file.close()

func vertex_dot(vertex: Node) -> String:
	var type: String = ""
	match vertex.type:
		TYPE_VERTEX.INIT: type = "I"
		TYPE_VERTEX.START: type = "S"
		TYPE_VERTEX.TASK: type = "T"
		TYPE_VERTEX.OBSTACLE: type = "O"
		TYPE_VERTEX.REWARD: type = "O"
		TYPE_VERTEX.SECRET: type = "St"
		TYPE_VERTEX.LOCK: type = "L"
		TYPE_VERTEX.KEY: type = "K"
		TYPE_VERTEX.GOAL: type = "G"
		_: type = "T"
	return vertex.name.substr(4,-1)
