extends ActionLeaf

func tick(actor: Node, _blackboard: Blackboard) -> int:
	var vision_area = actor.get_node("VisionArea")
	actor._lerp_anim_tree_param("WalkingBlend/blend_amount", 0.0)
	vision_area.rotation.y = lerp(vision_area.rotation.y, 0.0, 0.1)
		
	if abs(vision_area.rotation.y) < 0.001:
		return SUCCESS

	return RUNNING
