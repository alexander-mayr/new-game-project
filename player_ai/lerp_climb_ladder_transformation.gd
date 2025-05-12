extends ActionLeaf

func tick(actor: Node, _blackboard: Blackboard) -> int:
	var anim_tree = actor.get_node("AnimationTree")
	var param_string = "parameters/BlendSpace1D/0/ClimbLadder/blend_amount"
	actor.get_node("AuxScene").rotation.y = 0 # -PI/2
	actor.get_node("AuxScene").position.x = -1 * anim_tree.get(param_string)

	return SUCCESS
