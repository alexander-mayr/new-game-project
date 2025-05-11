extends ActionLeaf

func tick(actor: Node, _blackboard: Blackboard) -> int:
	var anim_tree = actor.get_node("AnimationTree")
	
	if anim_tree.get("parameters/HitToTheLeftBlend/blend_amount") > 0.01:
		actor._lerp_anim_tree_param("HitToTheLeftBlend/blend_amount", 0.0, 0.1)
		return RUNNING
	else:
		return SUCCESS
