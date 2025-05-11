extends ActionLeaf

func tick(actor: Node, _blackboard: Blackboard) -> int:
	actor.player.add_collision_exception_with(actor)
	return SUCCESS
