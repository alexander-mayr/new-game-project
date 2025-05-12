extends ActionLeaf

func tick(actor: Node, _blackboard: Blackboard) -> int:
	var anim_tree = actor.get_node("AnimationTree")
	var param_string = "parameters/BlendSpace1D/0/LeaveLadderUpper/blend_amount"
	actor.lerp_param(param_string, 1.0, 1.0)
	actor.get_node("AuxScene").rotation.y = 0

	if not _blackboard.get_value("tmp"):
		_blackboard.set_value("tmp", actor.global_position - Vector3(0, 1, 0))
		_blackboard.set_value("tmp2", Time.get_ticks_msec())
	
	var v = Globals.climb_to_top_anim.position_track_interpolate(0, (Time.get_ticks_msec() - _blackboard.get_value("tmp2"))/1000.0)
	actor.global_position = _blackboard.get_value("tmp") + v.rotated(Vector3.UP, actor.rotation.y)

	if _blackboard.get_value("last_animation_finished") == "ClimbingToTop":
		_blackboard.erase_value("tmp")
		_blackboard.set_value("last_animation_finished", "")
		return SUCCESS

	return RUNNING
