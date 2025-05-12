extends ActionLeaf

func tick(actor: Node, _blackboard: Blackboard) -> int:
	actor.lerp_param("parameters/BlendSpace1D/3/PickUpBody/blend_amount", 0.0)
	return SUCCESS
