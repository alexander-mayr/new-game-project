extends BlackboardHasCondition

func tick(actor: Node, _blackboard: Blackboard) -> int:
	if _blackboard.get_value("search_point") == null:
		var r = randi_range(2, 10)
		var q = randf_range(0, 2*PI)
		var sp = _blackboard.get_value("search_area") + Vector3(0, 0, r).rotated(Vector3.UP, q)
		_blackboard.set_value("search_point", sp)

	return SUCCESS
