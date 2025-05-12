extends ActionLeaf

func tick(actor: Node, _blackboard: Blackboard) -> int:
	var anim_tree = actor.get_node("AnimationTree")
	var param_string = "parameters/BlendSpace1D/0/StealthKill/blend_amount"
	actor.get_node("AuxScene").position.z = -1.245 * anim_tree.get("parameters/BlendSpace1D/0/StealthKill/blend_amount")
	actor.lerp_param(param_string, 1.0)

	if _blackboard.get_value("last_animation_finished") == "Stealth_Kill":
		return SUCCESS
	else:
		return RUNNING
