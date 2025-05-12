extends ConditionLeaf

func tick(actor: Node, _blackboard: Blackboard) -> int:
	if _blackboard.get_value("ladder_movement") == null or _blackboard.get_value("ladder_movement") == 0.0:
		return FAILURE
	else:
		return SUCCESS
