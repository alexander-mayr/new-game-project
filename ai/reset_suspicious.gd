extends ActionLeaf

func tick(actor: Node, _blackboard: Blackboard) -> int:
	_blackboard.set_value("investigation_area", null)
	_blackboard.set_value("areas_investigated", 0)
	_blackboard.set_value("suspicious_at", null)
	return SUCCESS
