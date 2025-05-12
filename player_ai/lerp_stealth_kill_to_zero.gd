extends ActionLeaf

func tick(actor: Node, _blackboard: Blackboard) -> int:
	var anim_tree = actor.get_node("AnimationTree")
	var param_string = "parameters/BlendSpace1D/0/StealthKill/blend_amount"
	actor.get_node("AuxScene").position.z = -1.245 * anim_tree.get(param_string)
	actor.lerp_param(param_string, 0.0)

	if anim_tree.get(param_string) > 0.1:
		return RUNNING
	else:
		return SUCCESS
