extends ActionLeaf

func tick(actor: Node, _blackboard: Blackboard) -> int:
	var anim_tree = actor.get_node("AnimationTree")
	var param_string = "parameters/BlendSpace1D/0/ClimbLadder/blend_amount"
	actor.get_node("AuxScene").rotation.y = PI
	actor.lerp_param(param_string, 1.0, 0.5)

	if anim_tree.get(param_string) < 0.99:
		return RUNNING
	else:
		return SUCCESS
