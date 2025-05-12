extends ActionLeaf

func tick(actor: Node, _blackboard: Blackboard) -> int:
	var anim_tree = actor.get_node("AnimationTree")
	var param_string = "parameters/BlendSpace1D/0/ClimbLadder/blend_amount"
	actor.get_node("AuxScene").rotation.y = 0
	actor.lerp_param(param_string, 0.0, 0.5)
	actor.get_node("FeetPoint").position.y = 0.0

	if anim_tree.get(param_string) > 0.1:
		return RUNNING
	else:
		anim_tree.set(param_string, 0.0)
		return SUCCESS
