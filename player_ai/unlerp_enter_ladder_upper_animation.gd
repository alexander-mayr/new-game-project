extends ActionLeaf

func tick(actor: Node, _blackboard: Blackboard) -> int:
	var anim_tree = actor.get_node("AnimationTree")
	var param_string = "parameters/BlendSpace1D/0/LeaveLadderUpper/blend_amount"

	actor.lerp_param(param_string, 0.0, 1.0)

	if anim_tree.get(param_string) > 0.1:
		return RUNNING
	else:
		anim_tree.set(param_string, 0.0)
		actor.set_ladder_pos((actor.global_position.y - actor.get_ladder().get_node("EntryPoint").global_position.y) + 1)
		_blackboard.erase_value("enter_ladder_upper")
		_blackboard.set_value("on_ladder", true)
		_blackboard.set_value("climb_ladder", true)
		return SUCCESS
