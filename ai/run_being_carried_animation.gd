extends ActionLeaf

func tick(actor: Node, _blackboard: Blackboard) -> int:
	actor.get_node("AnimationTree").set("parameters/BeingCarriedTimeScale/scale", 1.0)
	return SUCCESS
