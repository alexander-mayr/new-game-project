extends ConditionLeaf

func tick(actor: Node, _blackboard: Blackboard) -> int:
	if _blackboard.get_value("animation_to_blend") == null:
		var anim_tree = actor.get_node("AnimationTree")
		var guard_point = _blackboard.get_value("guard_point")
		var a = guard_point.global_position.direction_to(guard_point.next_point.global_position).normalized()
		var b = actor.global_position.direction_to(guard_point.global_position).normalized()

		if b.signed_angle_to(a, Vector3.UP) > 0:
			_blackboard.set_value("animation_to_blend", "LeftTurnBlend")
			anim_tree.set("parameters/LeftTurnTimeSeek/seek_request", 0.0)
			actor.velocity = Vector3.ZERO
		elif b.signed_angle_to(a, Vector3.UP) < 0:
			_blackboard.set_value("animation_to_blend", "RightTurnBlend")
			anim_tree.set("parameters/RightTurnTimeSeek/seek_request", 0.0)
			actor.velocity = Vector3.ZERO

	return SUCCESS
