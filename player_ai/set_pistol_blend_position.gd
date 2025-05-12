extends ActionLeaf

func tick(actor: Node, _blackboard: Blackboard) -> int:
	print(_blackboard.get_value("input_vector"))
	actor.lerp_param_vec("parameters/BlendSpace1D/" + _blackboard.get_value("stance_point_id") + "/PistolWalk/blend_position", _blackboard.get_value("input_vector"))
	return SUCCESS
