extends ActionLeaf

func tick(actor: Node, _blackboard: Blackboard) -> int:
	var anim_tree = actor.get_node("AnimationTree")
	var param_string = "parameters/BlendSpace1D/0/LeaveLadderUpper/blend_amount"
	var param_2_string = "parameters/BlendSpace1D/0/ClimbLadder/blend_amount"

	if not _blackboard.get_value("tmp"):
		_blackboard.set_value("tmp", Time.get_ticks_msec())
		_blackboard.set_value("tmp2", actor.global_position - Vector3(0, 3, 1))

	var t = (Time.get_ticks_msec() - _blackboard.get_value("tmp"))/1000.0
	var v = Globals.climb_to_top_anim.position_track_interpolate(0, 2.5 - t).rotated(Vector3.UP, PI)

	if t > 2.5:
		_blackboard.erase_value("tmp")
		return SUCCESS

	actor.global_position = _blackboard.get_value("tmp2") + v # actor.global_position.lerp(_blackboard.get_value("tmp2") + v, 1.0)
	actor.lerp_param(param_string, 1.0, 1.0)
	actor.lerp_param(param_2_string, 1.0, 1.0)

	return RUNNING
