extends ActionLeaf

func tick(actor: Node, _blackboard: Blackboard) -> int:
	var guard_point = _blackboard.get_value ("guard_point")
	_blackboard.set_value("guard_point", guard_point.next_point)
	return SUCCESS
