extends ActionLeaf

func tick(actor: Node, _blackboard: Blackboard) -> int:
	if actor.get_node("AnimationTree").get("parameters/BlendSpace1D/0/PickUpBody/blend_amount") < 0.9:
		actor.lerp_param("parameters/BlendSpace1D/0/PickUpBody/blend_amount", 0.0, 0.5)
	else:
		actor.lerp_param("parameters/BlendSpace1D/0/PickUpBody/blend_amount", 0.0, 0.005)

	if not _blackboard.get_value("carry_body"):
		_blackboard.set_value("carry_body", true)
		_blackboard.get_value("carry_body_target").global_position = Vector3(9999, 9999, 9999)
		actor.get_node("CarryBodyMeshPoint/CarryingBodyMesh").show()

	if actor.get_node("AnimationTree").get("parameters/BlendSpace1D/0/PickUpBody/blend_amount") > 0.1:
		return RUNNING
	else:
		return SUCCESS
