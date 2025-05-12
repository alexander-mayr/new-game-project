extends ActionLeaf

func tick(actor: Node, _blackboard: Blackboard) -> int:
	var anim_tree = actor.get_node("AnimationTree")
	var param_string = "parameters/BlendSpace1D/0/ClimbLadderTimeScale/scale"
	anim_tree.set(param_string, _blackboard.get_value("ladder_movement"))

	return SUCCESS
