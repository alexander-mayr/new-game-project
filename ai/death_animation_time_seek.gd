extends ActionLeaf

func tick(actor: Node, _blackboard: Blackboard) -> int:
	print("seek death")
	actor.get_node("AnimationTree").set("parameters/DyingTimeSeek/seek_request", 0.8)
	return SUCCESS
