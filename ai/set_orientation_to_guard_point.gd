extends ActionLeaf

func tick(actor: Node, _blackboard: Blackboard) -> int:
	actor.rotation.y = _blackboard.get_value("guard_point").rotation.y
	actor._lerp_anim_tree_param("WalkingBlend/blend_amount", 0.0)
	return SUCCESS
