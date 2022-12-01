extends Node2D

onready var gui = $"%GUI"
onready var graphs = $"%Graphs"

const Graph = preload("res://lite/graph/Graph.tscn")
const Vertex = preload("res://lite/vertex/Vertex.tscn")
const Edge = preload("res://lite/edge/Edge.tscn")

var targetGraph: Node2D = null
var indexGraph: int = 0
var indexVertex: int = 0
var recipe: Array = []
const DEFAULT_RECIPE: Array = [
	"randomInit",
	"randomExtend", "randomExtend", "randomExtend",
	"secret",
	"obstacle", "obstacle",
	"reward", "reward", "reward",
	"randomKeyLock", "randomKeyLock", "randomKeyLock"
]
var gridSize: Vector2 = Vector2(20,20)
var cellSize: Vector2 = Vector2(256,256)

const DIRECTIONS = [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]

# Called when the node enters the scene tree for the first time.
func _ready():
	recipe.append_array(DEFAULT_RECIPE)
	for rule in recipe:
		$"%RichTextRecipe".add_text(rule)
		$"%RichTextRecipe".newline()
	$Rule.cellSize = cellSize
	$RulePlace.cellSize = cellSize
	randomize()

func _input(event):
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == BUTTON_RIGHT:
		var mouse = get_viewport().get_mouse_position()
		if !event.control:
			$"%WindowDialogGenerator".popup(Rect2(mouse.x, mouse.y, $"%WindowDialogGenerator".rect_size.x, $"%WindowDialogGenerator".rect_size.y))
		else:
			$"%WindowDialogGraph".popup(Rect2(mouse.x, mouse.y, $"%WindowDialogGraph".rect_size.x, $"%WindowDialogGraph".rect_size.y))
#	if event is InputEventMouseButton and event.is_pressed() and event.button_index == BUTTON_LEFT:
#		if targetGraph != null:
#			print(targetGraph.get_vertex_by_position(get_global_mouse_position()))

#disable for performance
func _process(delta):
	if targetGraph == null:
		$"%ButtonDeleteGraph".disabled = true
		$"%ButtonExecuteSingleRule".disabled = true
		$"%ButtonExecuteRecipe".disabled = true
		$"%ButtonGetInfo".disabled = true
		$"%ButtonTransform".disabled = true
		$"%ButtonTransformKeyLock".disabled = true
		$"%ButtonGetMetaData".disabled = true
	else:
		$"%ButtonDeleteGraph".disabled = false
		$"%ButtonExecuteSingleRule".disabled = false
		$"%ButtonExecuteRecipe".disabled = false
		$"%ButtonGetInfo".disabled = false
		$"%ButtonTransform".disabled = false
		$"%ButtonTransformKeyLock".disabled = false
		$"%ButtonGetMetaData".disabled = false

func _create_graph():
	#make graph
	var graph = Graph.instance()
	graph.init_object("graph"+str(indexGraph), indexGraph)
	var posx = indexGraph * gridSize.x * cellSize.x
	graph.gridSize = gridSize
	graph.cellSize = cellSize
	graph.position = Vector2(posx, 0)
	graph.update()
	graphs.add_child(graph)
	
	#initiate vertex
	var vertexinit = graph.add_vertex("",TYPE_VERTEX.INIT)
	graph.connect_vertex(vertexinit, null)
	
	#add to option
	$"%OptionTargetGraph".add_item(graph.name, indexGraph)
	$"%OptionTargetGraph".select(indexGraph)
	$"%OptionTargetGraph2".add_item(graph.name, indexGraph)
	$"%OptionTargetGraph2".select(indexGraph)
	targetGraph = graph
	indexGraph += 1

func _execute_rule(rule: String, graph: Node2D):
	match rule:
		"init1":
			$Rule.rule_init_1(graph)
		"init2":
			$Rule.rule_init_2(graph)
		"extend1":
			$Rule.rule_extend_1(graph)
		"extend2":
			$Rule.rule_extend_2(graph)
		"extend3":
			$Rule.rule_extend_3(graph)
		"secret":
			$Rule.rule_secret(graph)
		"obstacle":
			$Rule.rule_obstacle(graph)
		"reward":
			$Rule.rule_reward(graph)
		"key&lock1":
			$Rule.rule_knl_1(graph)
		"key&lock2":
			$Rule.rule_knl_2(graph)
		"key&lock3":
			$Rule.rule_knl_3(graph)
		"key&lock4":
			$Rule.rule_knl_4(graph)
		"randomInit":
			$Rule.random_init(graph)
		"randomExtend":
			$Rule.random_extend(graph)
		"randomKeyLock":
			$Rule.random_knl(graph)
		"create_place_rule":
			$RulePlace.create_place_rule(graph)
		"clean_outside_element_rule":
			$RulePlace.clean_outside_element_rule(graph)
		"make_edges_element":
			$RulePlace.make_edges_element(graph)
		"make_room_and_cave":
			$RulePlace.make_room_and_cave(graph)
		"make_hidden_path":
			$RulePlace.make_hidden_path(graph)
		"make_window":
			$RulePlace.make_window(graph)
		"make_gate":
			$RulePlace.make_gate(graph)
		"duplicate_key":
			$RuleTransformKL.duplicate_key(graph)
		"duplicate_lock":
			$RuleTransformKL.duplicate_lock(graph)
		"move_lock_toward":
			$RuleTransformKL.move_lock_toward(graph)
		"move_key_duplicate_backward":
			$RuleTransformKL.move_key_duplicate_backward(graph)
	graph.update()

func _execute_place_rule(graph: Node2D):
	_execute_rule("create_place_rule", graph)
	_execute_rule("clean_outside_element_rule", graph)
	_execute_rule("make_edges_element", graph)
	_execute_rule("make_room_and_cave", graph)
	_execute_rule("make_hidden_path", graph)
	yield(VisualServer, 'frame_post_draw')
	_execute_rule("make_window", graph)
	_execute_rule("make_gate", graph)
	graph.update()

func _execute_transform_key_rule(graph: Node2D):
	_execute_rule("duplicate_key", graph)
	_execute_rule("duplicate_lock", graph)
	_execute_rule("move_lock_toward", graph)
	_execute_rule("move_key_duplicate_backward", graph)

func _on_ButtonAddGraph_pressed():
	_create_graph()

func _on_OptionTargetGraph_item_selected(index):
	targetGraph = get_node("Graphs/" + $"%OptionTargetGraph".get_item_text(index))
	$"%OptionTargetGraph2".select($"%OptionTargetGraph".get_selected_id())


func _on_ButtonDeleteGraph_pressed():
	targetGraph.queue_free()
	targetGraph = null
	$"%OptionTargetGraph".remove_item($"%OptionTargetGraph".get_selected_id())
	$"%OptionTargetGraph2".remove_item($"%OptionTargetGraph2".get_selected_id())
	$"%OptionTargetGraph".select(-1)
	$"%OptionTargetGraph2".select(-1)


func _on_ButtonExecuteSingleRule_pressed():
	var selectedRule = $"%OptionSingleRule".get_item_text($"%OptionSingleRule".get_selected_id())
	_execute_rule(selectedRule, targetGraph)


func _on_ButtonAddRule_pressed():
	var textItem = $"%OptionRuleRecipe".get_item_text($"%OptionRuleRecipe".get_selected_id())
	recipe.append(textItem)
	$"%RichTextRecipe".add_text(textItem)
	$"%RichTextRecipe".newline()


func _on_ButtonExecuteRecipe_pressed():
	for rule in recipe:
		_execute_rule(rule, targetGraph)


func _on_ButtonClearRecipe_pressed():
	recipe.clear()
	$"%RichTextRecipe".clear()


func _on_ButtonClearAll_pressed():
	for graph in graphs.get_children():
		graph.queue_free()
	targetGraph = null
	$"%OptionTargetGraph".clear()
	$"%OptionTargetGraph2".clear()
	indexGraph = 0
	indexVertex = 0
	recipe.clear()
	recipe.append_array(DEFAULT_RECIPE)
	$"%RichTextRecipe".clear()
	for rule in recipe:
		$"%RichTextRecipe".add_text(rule)
		$"%RichTextRecipe".newline()


func _on_OptionTargetGraph2_item_selected(index):
	targetGraph = get_node("Graphs/" + $"%OptionTargetGraph".get_item_text(index))
	$"%OptionTargetGraph".select($"%OptionTargetGraph2".get_selected_id())


func _on_ButtonGetInfo_pressed():
	if targetGraph != null:
		var fitness = targetGraph.get_fitness()
		$"%Labelvariation".text = "variation : " + str(targetGraph.variation)
		$"%Labelexploration".text = "exploration : " + str(targetGraph.exploration)
		$"%LabelshortesPathLength".text = "shortesPathLength : " + str(targetGraph.shortesPathLength)
		$"%LabelstandardShortPath".text = "standardShortPath : " + str(targetGraph.standardShortPath)
		$"%LabelweightDuration".text = "weightDuration : " + str(targetGraph.weightDuration)
		$"%LabeloptionReplay".text = "optionReplay : " + str(targetGraph.optionReplay)
		$"%Labelfitness".text = "fitness : " + str(fitness)


func _on_ButtonTransform_pressed():
	_execute_place_rule(targetGraph)


func _on_ButtonTransformKeyLock_pressed():
	_execute_transform_key_rule(targetGraph)


func _on_ButtonGetMetaData_pressed():
	var metadata: Dictionary = targetGraph.get_meta_data()
	var path = "C:/SourceCode/level-generator-with-graph-godot/graph.json"
#	print(JSON.print(metadata, "\t"))
	var file
	file = File.new()
	file.open(path, File.WRITE)
	file.store_line(JSON.print(metadata, "\t"))
	file.close()
