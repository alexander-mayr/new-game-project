extends ActionLeaf

func tick(actor: Node, _blackboard: Blackboard) -> int:
	actor.lerp_to_stance(0.5)
	_blackboard.set_value("stance_point_id", "3")
	return SUCCESS
