extends ActionLeaf

func tick(actor: Node, _blackboard: Blackboard) -> int:
	var anim_tree = actor.get_node("AnimationTree")
	var param_string = "parameters/BlendSpace1D/0/Running/blend_amount"
	actor.lerp_param(param_string, 0.0)
	return SUCCESS
