extends ActionLeaf

func tick(actor: Node, _blackboard: Blackboard) -> int:
	var vision_area = actor.get_node("VisionArea")
	actor._lerp_anim_tree_param("WalkingBlend/blend_amount", 0.0)

	if not _blackboard.get_value("looked_left"):
		vision_area.rotation.y = lerp(vision_area.rotation.y, PI/4, 0.1)

		if abs(vision_area.rotation.y - PI/4) < 0.001:
			_blackboard.set_value("looked_left", true)
	elif not _blackboard.get_value("looked_center"):
		vision_area.rotation.y = lerp(vision_area.rotation.y, 0.0, 0.1)
		
		if abs(vision_area.rotation.y) < 0.001:
			_blackboard.set_value("looked_center", true)
	elif not _blackboard.get_value("looked_right"):
			vision_area.rotation.y = lerp(vision_area.rotation.y, -PI/4, 0.1)

			if abs(vision_area.rotation.y + PI/4) < 0.001:
				_blackboard.set_value("looked_right", true)
	else:
		vision_area.rotation.y = lerp(vision_area.rotation.y, 0.0, 0.1)
			
		if abs(vision_area.rotation.y) < 0.001:
			_blackboard.set_value("looked_right", false)
			_blackboard.set_value("looked_left", false)
			_blackboard.set_value("looked_center", false)
			return SUCCESS

	return RUNNING
