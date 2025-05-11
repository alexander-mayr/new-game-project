extends ActionLeaf

func tick(actor: Node, _blackboard: Blackboard) -> int:
	_blackboard.set_value("investigation_area", null)
	_blackboard.set_value("areas_investigated", _blackboard.get_value("areas_investigated") + 1)
	return SUCCESS
