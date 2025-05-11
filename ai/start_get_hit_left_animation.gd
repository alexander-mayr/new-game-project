extends ActionLeaf

func tick(actor: Node, _blackboard: Blackboard) -> int:
	var anim_tree = actor.get_node("AnimationTree")
	actor._lerp_anim_tree_param("HitToTheLeftBlend/blend_amount", 1.0)

	if anim_tree.get("parameters/HitToTheLeftBlend/blend_amount") < 0.99:
		return RUNNING
	else:
		return SUCCESS
