extends ActionLeaf

func tick(actor: Node, _blackboard: Blackboard) -> int:
	actor.get_node("AnimationTree").set("parameters/HitToTheLeftTimeSeek/seek_request", 0.3)
	return SUCCESS
