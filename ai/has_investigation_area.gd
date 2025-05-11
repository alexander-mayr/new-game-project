extends ConditionLeaf

func tick(actor: Node, _blackboard: Blackboard) -> int:
	if _blackboard.get_value("investigation_area") == null:
		var r = randi_range(2, 10)
		var q = randf_range(0, 2*PI)
		r = 1
		q = 0.0
		var investigation_area = _blackboard.get_value("investigation_area") + Vector3(0, 0, r).rotated(Vector3.UP, q)
		_blackboard.set_value("investigation_area", investigation_area)

	return SUCCESS
