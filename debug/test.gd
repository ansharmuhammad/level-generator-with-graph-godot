extends Node2D

func _draw():
	draw_line($VisualNode.global_position - Vector2(140,0).rotated($VisualNode.global_position.angle_to_point($VisualNode2.global_position)), $VisualNode2.global_position - Vector2(140,0).rotated($VisualNode2.global_position.angle_to_point($VisualNode.global_position)), Color.yellow, 5)
	draw_line($VisualNode.global_position, $VisualNode3.global_position, Color.yellow, 10)
	draw_line($VisualNode.global_position, $VisualNode4.global_position, Color.yellow, 10)
	draw_line($VisualNode.global_position, $VisualNode5.global_position, Color.yellow, 10)
	

func _physics_process(delta):
	if $VisualNode.get_mode() != RigidBody2D.MODE_STATIC:
		$VisualNode.set_mode(RigidBody2D.MODE_STATIC)
	update()
