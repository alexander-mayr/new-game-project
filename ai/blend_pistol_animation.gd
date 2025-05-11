extends ActionLeaf

func tick(actor: Node, _blackboard: Blackboard) -> int:
	actor._lerp_anim_tree_param("PistolWalkBlend/blend_amount", 1.0)
	return SUCCESS
