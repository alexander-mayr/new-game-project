extends ConditionLeaf

func tick(actor: Node, _blackboard: Blackboard) -> int:
	if _blackboard.get_value("guard_point").next_point == null:
		return FAILURE
	else:
		return SUCCESS
