extends ActionLeaf

func tick(actor: Node, _blackboard: Blackboard) -> int:
	actor.lerp_to_stance(-1.0)
	_blackboard.set_value("stance_point_id", "2")
	return SUCCESS
