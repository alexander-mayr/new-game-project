extends ActionLeaf

func tick(actor: Node, _blackboard: Blackboard) -> int:
	actor.lerp_param("parameters/BlendSpace1D/0/PickUpBody/blend_amount", 1.0)

	if actor.get_node("AnimationTree").get("parameters/BlendSpace1D/0/PickUpBody/blend_amount") < 0.99:
		return RUNNING
	else:
		return SUCCESS
