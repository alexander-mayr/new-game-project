extends ActionLeaf

func tick(actor: Node, _blackboard: Blackboard) -> int:
	var nav_agent = actor.get_node("NavigationAgent3D")
	nav_agent.target_position = _blackboard.get_value("search_point")
	
	if nav_agent.is_navigation_finished():
		return SUCCESS
	else:
		return RUNNING
