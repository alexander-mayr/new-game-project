extends ActionLeaf

func tick(actor: Node, _blackboard: Blackboard) -> int:
	var anim_tree = actor.get_node("AnimationTree")
	var param_string = "parameters/BlendSpace1D/0/LeaveLadderUpper/blend_amount"
	var param_2_string = "parameters/BlendSpace1D/0/ClimbLadder/blend_amount"
	
	actor.lerp_param(param_string, 0.0, 0.25)
	actor.lerp_param(param_2_string, 0.0, 0.25)
	_blackboard.erase_value("on_ladder")

	if anim_tree.get(param_string) > 0.1 or anim_tree.get(param_2_string) > 0.1:
		return RUNNING
	else:
		actor.get_node("AuxScene").rotation.y = 0
		anim_tree.set(param_string, 0.0)
		anim_tree.set(param_2_string, 0.0)
		actor.cam.unlock()
		#_blackboard.erase_value("leave_ladder_upper")
		#_blackboard.erase_value("climb_ladder")
		actor.set_ladder(null)
		return SUCCESS
