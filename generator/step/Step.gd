extends Node

export var repeat: int = 1

func execute(graph: Node):
	if get_child_count() > 0:
		var rules: Array = get_children()
		for n in range(repeat):
			randomize()
			var chosenRule = rules[randi() % rules.size()]
			chosenRule.execute(graph)
