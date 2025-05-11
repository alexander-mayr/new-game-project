extends ActionLeaf

func tick(actor: Node, _blackboard: Blackboard) -> int:
	var blend_name = _blackboard.get_value("animation_to_blend")
	var anim_tree = actor.get_node("AnimationTree")
	anim_tree.set("parameters/" + blend_name + "/blend_amount", 0.0)

	return SUCCESS
