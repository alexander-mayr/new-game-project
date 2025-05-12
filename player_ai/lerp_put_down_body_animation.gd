extends ActionLeaf

func tick(actor: Node, _blackboard: Blackboard) -> int:
	actor.lerp_param("parameters/BlendSpace1D/3/PutBodyDown/blend_amount", 1.0)
	var blend_value = actor.get_node("AnimationTree").get("parameters/BlendSpace1D/3/PutBodyDown/blend_amount")
	actor.get_node("CarryBodyMeshPoint").global_position.y = -blend_value * 0.5

	if blend_value > 0.7:
		var body = _blackboard.get_value("carry_body_target")
		actor.get_node("CarryBodyMeshPoint/CarryingBodyMesh").hide()
		body.global_position = actor.global_position + Vector3(1, 0, 0).rotated(Vector3.UP, actor.rotation.y)
		body.rotation.y = actor.rotation.y + PI/2 * PI
	if blend_value < 0.99:
		return RUNNING
	else:
		return SUCCESS
   
