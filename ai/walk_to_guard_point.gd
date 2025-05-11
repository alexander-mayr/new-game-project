extends ActionLeaf

func tick(actor: Node, _blackboard: Blackboard) -> int:
	var nav_agent = actor.get_node("NavigationAgent3D")
	var anim_tree = actor.get_node("AnimationTree")
	nav_agent.target_position = _blackboard.get_value("guard_point").global_position
	
	if nav_agent.is_navigation_finished():
		actor._lerp_anim_tree_param("WalkingBlend/blend_amount", 0.0, 1.0)
		return SUCCESS
	else:
		actor._lerp_anim_tree_param("RightTurnBlend/blend_amount", 0.0)
		actor._lerp_anim_tree_param("LeftTurnBlend/blend_amount", 0.0)
		actor._lerp_anim_tree_param("WalkingBlend/blend_amount", 1.0)
		return RUNNING
	
