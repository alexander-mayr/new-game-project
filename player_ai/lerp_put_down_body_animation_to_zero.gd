extends ActionLeaf

func tick(actor: Node, _blackboard: Blackboard) -> int:
	actor.lerp_param("parameters/BlendSpace1D/3/PutBodyDown/blend_amount", 0.0, 0.1)

	if actor.get_node("AnimationTree").get("parameters/BlendSpace1D/3/PutBodyDown/blend_amount") > 0.1:
		return RUNNING
	else:
		return SUCCESS
