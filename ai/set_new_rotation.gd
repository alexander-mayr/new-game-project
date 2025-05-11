extends ActionLeaf

func tick(actor: Node, _blackboard: Blackboard) -> int:
	var blend_name = _blackboard.get_value("animation_to_blend")

	if blend_name == "RightTurnBlend":
		actor.rotation.y = actor.rotation.y - PI/2
	elif blend_name == "LeftTurnBlend":
		actor.rotation.y = actor.rotation.y + PI/2

	actor.global_position += Vector3(0, 0, 0.15).rotated(Vector3.UP, actor.rotation.y)
	return SUCCESS
