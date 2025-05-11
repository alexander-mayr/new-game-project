extends ActionLeaf

func tick(actor: Node, _blackboard: Blackboard) -> int:
	var blend_name = _blackboard.get_value("animation_to_blend")
	var anim_tree = actor.get_node("AnimationTree")
	actor._lerp_anim_tree_param(blend_name + "/blend_amount", 0.0)

	if anim_tree.get("parameters/" + blend_name + "/blend_amount") > 0.01:
		return RUNNING
	else:
		return SUCCESS
