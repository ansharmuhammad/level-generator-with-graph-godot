extends Node2D

onready var file: File = File.new()

func _ready():
	file.open("res://generator/loggen.txt", File.WRITE)
	file.store_line("==============================================================================")
	file.close()

func to_dot(graph: Node):
	file.open("res://generator/loggen.txt", File.READ_WRITE)
	file.seek_end()
	file.store_line("digraph G {")
	file.store_line('node [shape="circle"]')
	for edge in graph.get_edges():
		var vertex1: Node = graph.get_vertex_by_name(edge.from)
		var vertex2: Node = graph.get_vertex_by_name(edge.to)
		if (vertex1 != null and vertex2 != null) and (vertex1.subOf == null and vertex2.subOf == null):
			if edge.type == TYPE_EDGE.PATH:
				file.store_line('"'+vertex_dot(vertex1)+'"' + " -> " + '"'+vertex_dot(vertex2)+'"')
			else:
				file.store_line('"'+vertex_dot(vertex1)+'"' + " -> " + '"'+vertex_dot(vertex2)+'" [ style=dashed ]')
	for vertex in graph.get_vertices():
		if vertex.type == TYPE_VERTEX.START and vertex.subOf == null:
			file.store_line('"'+vertex_dot(vertex)+'"' + " [peripheries=2]")
		if vertex.type == TYPE_VERTEX.GOAL and vertex.subOf == null:
			file.store_line('"'+vertex_dot(vertex)+'"' + " [peripheries=2]")
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
#	return vertex.name.substr(4,-1) + ":" + type
	return vertex.name.substr(4,-1)

# draw graph with sugiyama framework
# method:
# 1. Eliminate cycles
# 2. Assign nodes to levels
# 3. Minimize edge crosses
# 4. Assign nodes to cartesian coordinates
# 5. Restore original cycles

# 1. Eliminate cycles, build succession with minimal count of backedge.
#   (a) Save sources and sinks in two different lists
#   (b) Remove source nodes successively and add to source list
#   (c) remove sink nodes successively and add to sink list
#   (d) chose next candidate according to in- and out-rank of node, rangOut = maxNode( [R_out(v) - R_in(v) for v in G] )
#   (e) remove v from Graph and add to source list
func _cycle_analysis(graph: Node) -> Array:
	var G: Node = graph.duplicate()
	var S: Array = []
	
	#Sl & Sr in sugiyama
	var Sl: Array = []
	var Sr: Array = []
	var tempEdge: Array = []
	
	while !G.get_vertices().empty():
		# (a)
		var sources: Array = G.get_sources()
		var sinks: Array = G.get_sinks()
		
		# (b)
		if sources.size() > 0:
			Sl.append_array(sources)
			
			for n in sources:
				for e in G.get_edges_of(n, TYPE_EDGE.PATH):
					e.queue_free()
				G.remove_child(G.get_node("Vertices/" + n.name))
		
		# (c)
		if sinks.size() > 0:
			Sr.append_array(sinks)
			
			for n in sinks:
				for e in G.get_edges_of(n, TYPE_EDGE.PATH):
					e.queue_free()
				G.remove_child(G.get_node("Vertices/" + n.name))
		
		# (d)
		elif !G.get_vertices().empty():
			var vertexMaxOutDegree: Node = null
			var maxOutDegree: int = 0
			for n in G.get_vertices():
				var Od = G.get_outdegree(n, TYPE_EDGE.PATH) 
				if Od > maxOutDegree:
					maxOutDegree = Od
					vertexMaxOutDegree = n
			# (e)
			if vertexMaxOutDegree != null :
				Sl.append(vertexMaxOutDegree)
				for e in G.get_edges_of(vertexMaxOutDegree, TYPE_EDGE.PATH):
					e.queue_free()
				G.remove_child(G.get_node("Vertices/" + vertexMaxOutDegree.name))
	
	G.queue_free()
	S.append_array(Sl)
	S.append_array(Sr)
	return S
	# NOTE: free all node in S after use this func

# invert cyclic edge
func _invert_back_edges(graph: Node, S: Array) -> Node:
	var G: Node = graph.duplicate()
	for n in S:
		for edge in G.get_edges_of(n):
			G.invert_edge(edge)
	
	return G
	# NOTE: free all node G after use this func

# 2. Assign each node to horizontal Level
#   (a) Determine sinks
#   (b) Assign them to new level
#   (c) Deleate all sinks from graph 

# takes acyclic Graph
func _level_assignment(graph: Node) -> Array:
	var G: Node = graph.duplicate()
	var L: Array = [] # levels
	
	while !G.get_vertices().empty():
		# (a)
		var sinks: Array = G.get_sinks()
		
		# (c)
		L.append(sinks)
		
		# (b)
		for n in sinks:
			G.remove_child(G.get_node("Vertices/" + n.name))
	
	G.queue_free()
	L.invert()
	return L
	# NOTE: free all node in L [[,,,]] after use this func

# take (a, b) and if there lies a level between them (which they are not connected over):
#   take a as from node, 
#   create a new node
#     connect that new node to a
#   connect that new node to b
# for multiple levels in between
#func _solved_mid_transition(graph: Node, edge: Node, L: Array):
	# return the levels that lie between the node
	
#def solveMidTransition(N, edge, L):
#    (a, b) = edge
#
#    # return the levels that lie between the node
#
#    lfrom = N[a]['level']
#    lto = N[b]['level']
#
#    if lto < lfrom:
#        step = -1
#    else:
#        step = 1
#
#    removeEdges(N, [ (a, b) ])   # remove original edge
#
#    u = a   # (u, v)
#    for i in range(lfrom + step, lto, step):     # for levels between a and b
#        v = ''.join(random.choice(string.ascii_uppercase + string.digits) for _ in range(3))
#
#        N[u]['out'] += [ v ]
#        N[v] = {'in': [u], 'out': [], 'level': i, 'between': True }
#        L[i] += [ v ]      # add to level
#        u = v
#
#    N[v]['out'] += [ b ]     # u is last created node... connect that one to b
#    N[b]['in'] += [ u ]     # u is last created node... connect that one to b
#
#    return N, L

#reference N[node] = {'in': [], 'out': []}
