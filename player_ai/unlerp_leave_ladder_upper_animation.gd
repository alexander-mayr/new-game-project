extends ActionLeaf

func tick(actor: Node, _blackboard: Blackboard) -> int:
	var anim_tree = actor.get_node("AnimationTree")
	var param_string = "parameters/BlendSpace1D/0/LeaveLadderUpper/blend_amount"
	var param_2_string = "parameters/BlendSpace1D/0/ClimbLadder/blend_amount"
	
	actor.lerp_param(param_string, 0.0, 0.5)
	actor.lerp_param(param_2_string, 0.0, 0.5)
	_blackboard.erase_value("on_ladder")

	if anim_tree.get(param_string) > 0.01 or anim_tree.get(param_2_string) > 0.01 or actor.get_node("AuxScene").rotation.y > 0.0:
		return RUNNING
	else:
		#print("do")
		anim_tree.set(param_string, 0.0)
		anim_tree.set(param_2_string, 0.0)
		actor.set_ladder(null)
		#return RUNNING
	
		return SUCCESS
