extends ActionLeaf

func tick(actor: Node, _blackboard: Blackboard) -> int:
	#return SUCCESS

	var anim_tree = actor.get_node("AnimationTree")
	var param_string = "parameters/BlendSpace1D/" + _blackboard.get_value("stance_point_id") + "/FreeMovement/blend_amount"
	actor.lerp_param(param_string, 0.0)
	return SUCCESS
