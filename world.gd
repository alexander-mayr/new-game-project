extends Node3D

func _ready() -> void:
	for pt in get_tree().get_nodes_in_group("guard_points"):
		if pt.spawn_guard:
			var guard = preload("res://guard.tscn").instantiate()
			add_child(guard)
			guard.global_position = pt.global_position
			guard.rotation_degrees = pt.rotation_degrees
			guard.get_node("Blackboard").set_value("guard_point", pt)

func set_action_tooltip(text):
	$CanvasLayer/ActionLabel.text = text
	$CanvasLayer/ActionLabel.show()
	$CanvasLayer/ActionPanel.show()

func clear_action_tooltip():
	$CanvasLayer/ActionLabel.text = ""
	$CanvasLayer/ActionLabel.hide()
	$CanvasLayer/ActionPanel.hide()

func _process(delta: float) -> void:
	#print(Engine.get_frames_per_second())
	$CanvasLayer/Reticle.position = get_viewport().get_visible_rect().size/2.0 - Vector2(16, 16)
	$CanvasLayer/ActionLabel.position = get_viewport().get_visible_rect().size/2.0 - Vector2(-30, 30)
	$CanvasLayer/ActionPanel.position = get_viewport().get_visible_rect().size/2.0 - Vector2(-30, 30)

	if $PlayerCharacter.is_hidden():
		$CanvasLayer/HiddenIndicator.show()
		$CanvasLayer/VisibleIndicator.hide()
	else:
		$CanvasLayer/HiddenIndicator.hide()
		$CanvasLayer/VisibleIndicator.show()
