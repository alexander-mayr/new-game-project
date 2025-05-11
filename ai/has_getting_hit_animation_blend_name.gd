extends ConditionLeaf

func tick(actor: Node, _blackboard: Blackboard) -> int:
	if _blackboard.get_value("getting_hit_front") == true:
		_blackboard.set_value("getting_hit_animation_blend_name", "HitToBodyBlend")
	elif _blackboard.get_value("getting_hit_back") == true:
		_blackboard.set_value("getting_hit_animation_blend_name", "HitToBodyBlend")
	elif _blackboard.get_value("getting_hit_left") == true:
		_blackboard.set_value("getting_hit_animation_blend_name", "HitToTheLeftBlend")
	elif _blackboard.get_value("getting_hit_right") == true:
		_blackboard.set_value("getting_hit_animation_blend_name", "HitToTheRightBlend")
	elif _blackboard.get_value("getting_hit_head") == true:
		_blackboard.set_value("getting_hit_animation_blend_name", "HitToBodyBlend")
	else:
		return FAILURE

	return SUCCESS
