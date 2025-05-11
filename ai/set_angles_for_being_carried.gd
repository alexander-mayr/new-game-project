extends ActionLeaf

func tick(actor: Node, _blackboard: Blackboard) -> int:
	#print("a")
	actor.rotation.y = deg_to_rad(0)
	actor.rotation.z = deg_to_rad(13) # deg_to_rad(12.4)
	actor.get_node("AnimationTree").set("parameters/DyingBlend/blend_amount", 0.0)
	return SUCCESS
