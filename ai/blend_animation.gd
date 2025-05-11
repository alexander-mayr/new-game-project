extends ActionLeaf

func tick(actor: Node, _blackboard: Blackboard) -> int:
	var blend_name = _blackboard.get_value("animation_to_blend")
	var anim_tree = actor.get_node("AnimationTree")
	var amount = 1.0

	if _blackboard.get_value("animation_to_blend_amount") != null:
		amount = _blackboard.get_value("animation_to_blend_amount")

	actor._lerp_anim_tree_param(blend_name + "/blend_amount", amount)

	if _blackboard.get_value("animation_to_blend_no_wait") == true:
		if anim_tree.get("parameters/" + blend_name + "/blend_amount") > 0.99:
			return SUCCESS
		else:
			return RUNNING
	else:
		var s = _blackboard.get_value("last_animation_finished")
		if s == null:
			s = ""
		if s + "Blend" == blend_name:
			return SUCCESS
		else:
			return RUNNING
