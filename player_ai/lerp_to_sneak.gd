extends ActionLeaf

func tick(actor: Node, _blackboard: Blackboard) -> int:
	actor.lerp_to_stance(-0.5)
	_blackboard.set_value("stance_point_id", "1")
	actor.lerp_param("parameters/BlendSpace1D/1/PistolWalk/4/PistolWalkIdleKneeling/blend_amount", 1.0)
	actor.lerp_param("parameters/BlendSpace1D/0/PistolWalk/4/PistolWalkIdleKneeling/blend_amount", 1.0)
	return SUCCESS
