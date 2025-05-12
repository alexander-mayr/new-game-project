extends ActionLeaf

func tick(actor: Node, _blackboard: Blackboard) -> int:
	print("a")
	actor.get_node("AuxScene").position.x -= 1
	return SUCCESS
