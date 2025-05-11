extends ActionLeaf

func tick(actor: Node, _blackboard: Blackboard) -> int:
	actor._lerp_anim_tree_param("DyingBlend/blend_amount", 1.0)
	var anim_tree = actor.get_node("AnimationTree")

	if anim_tree.get("parameters/DyingBlend/blend_amount") < 0.99:
		return RUNNING
	else:
		return SUCCESS
