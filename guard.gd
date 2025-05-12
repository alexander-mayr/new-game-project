extends CharacterBody3D

const MAX_HEALTH = 2

var player_spotted_counter = 0.0
var player_in_vision_area = false
var player_visible = false
var player_spotted = false

var npcs_in_view = []

@onready var player = get_tree().get_first_node_in_group("player_character")

func disappear():
	global_position = Vector3(9999, 9999, 9999)

func _process(delta: float) -> void:
	for npc in npcs_in_view:
		if npc._currently_getting_hit():
			if $Blackboard.get_value("search_area") == null:
				$Blackboard.set_value("search_area", npc.global_position)
				$BeehaveTree.interrupt()

func stop_getting_carried_movement():
	$Blackboard.erase_value("getting_carried_movement")

func start_getting_carried_movement():
	$Blackboard.set_value("getting_carried_movement", true)

func start_getting_carried():
	$Blackboard.set_value("getting_carried", true)
	$BeehaveTree.interrupt()

func start_getting_stealth_killed():
	$Blackboard.set_value("stealth_killed", true)
	$BeehaveTree.interrupt()

func get_health():
	return $Blackboard.get_value("health")

func _ready() -> void:
	$Blackboard.set_value("health", MAX_HEALTH)
	$Blackboard.set_value("points_searched", 0)
	$Blackboard.set_value("speed_factor", 1)
	$Blackboard.set_value("last_animation_finished", "")

func _currently_getting_hit():
	return $Blackboard.get_value("getting_hit_left") == true or $Blackboard.get_value("getting_hit_right") or \
		$Blackboard.get_value("getting_hit_back") == true or $Blackboard.get_value("getting_hit_front") == true

func get_hit_left(dmg):
	$Blackboard.set_value("health", $Blackboard.get_value("health") - dmg)

	if not _currently_getting_hit():
		$Blackboard.set_value("getting_hit_left", true)
		$Blackboard.set_value("search_area", global_position)
		$BeehaveTree.interrupt()

	if get_health() <= 0:
		$BeehaveTree.interrupt()
		
func get_hit_right(dmg):
	$Blackboard.set_value("health", $Blackboard.get_value("health") - dmg)

	if not _currently_getting_hit():
		$Blackboard.set_value("getting_hit_right", true)
		$Blackboard.set_value("search_area", global_position)
		$BeehaveTree.interrupt()

	if get_health() <= 0:
		$BeehaveTree.interrupt()

func get_hit_front(dmg):
	$Blackboard.set_value("health", $Blackboard.get_value("health") - dmg)

	if not _currently_getting_hit():
		$Blackboard.set_value("getting_hit_front", true)
		$Blackboard.set_value("search_area", global_position)
		$BeehaveTree.interrupt()

	if get_health() <= 0:
		$BeehaveTree.interrupt()

func get_hit_back(dmg):
	$Blackboard.set_value("health", $Blackboard.get_value("health") - dmg)

	if not _currently_getting_hit():
		$Blackboard.set_value("getting_hit_back", true)
		$Blackboard.set_value("search_area", global_position)
		$BeehaveTree.interrupt()

	if get_health() <= 0:
		$BeehaveTree.interrupt()

func get_hit_head(dmg):
	$Blackboard.set_value("health", $Blackboard.get_value("health") - 2 * dmg)

	if not _currently_getting_hit():
		$Blackboard.set_value("getting_hit_head", true)
		$Blackboard.set_value("search_area", global_position)
		$BeehaveTree.interrupt()

	if get_health() <= 0:
		$BeehaveTree.interrupt()

func _lerp_anim_tree_param(param_name, target, t = 0.1):
	var param_string = "parameters/" + param_name
	var param_value = float($AnimationTree.get(param_string))
	$AnimationTree.set(param_string, lerp(param_value, target, t))

func _check_player_spotted(delta):
	var time_to_spotted = 1.5

	if player_visible:
		var c = 1.0

		if player.in_sneak_stance():
			c = 0.5
		
		if player.in_prone_stance():
			c = 0.25
		player_spotted_counter += delta * c * 3
	else:
		player_spotted_counter -= delta * 2
		
	if player_spotted_counter >= time_to_spotted:
		player_spotted_counter = time_to_spotted
		player_spotted = true
	elif player_spotted_counter <= 0:
		player_spotted_counter = 0
		player_spotted = false

	if player_spotted_counter > 0:
		get_node("/root/World/CanvasLayer/DetectionUI").add_meter(self)

func _check_player_visibility():
	if not player_in_vision_area:
		player_visible = false
		return

	var to = null

	if player.in_sneak_stance():
		to = player.get_node("DetectionPointSneaking").global_position
	elif player.in_prone_stance():
		to = player.get_node("DetectionPointProne").global_position
	else:
		to = player.get_node("DetectionPoint").global_position

	var query = PhysicsRayQueryParameters3D.create($VisionPoint.global_position, to, 2, [self])
	var result = get_world_3d().direct_space_state.intersect_ray(query)

	if result != {} and result["collider"] == player:
		if player.is_hidden():
			player_visible = false
		else:
			player_visible = true
	else:
		player_visible = false

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= 10 * delta

	_check_player_visibility()
	_check_player_spotted(delta)

	if not $NavigationAgent3D.is_navigation_finished():
		var d = global_position.direction_to($NavigationAgent3D.get_next_path_position()).normalized()
		velocity.x = d.x * $Blackboard.get_value("speed_factor")
		velocity.z = d.z * $Blackboard.get_value("speed_factor")
		
		rotation.y = Vector2(velocity.x, velocity.z).angle_to(Vector2(0, 1))
	else:
		velocity.x = 0
		velocity.z = 0
	
	move_and_slide()

func _on_vision_area_body_entered(body: Node3D) -> void:
	if body == player:
		player_in_vision_area = true
	elif body.has_meta("is_npc") and body != self and body not in npcs_in_view:
		npcs_in_view.append(body)

func _on_vision_area_body_exited(body: Node3D) -> void:
	if body == player:
		player_in_vision_area = false
	elif body.has_meta("is_npc"):
		npcs_in_view.erase(body)

var last_animation_finished = null

func _on_animation_tree_animation_finished(anim_name: StringName) -> void:
	$Blackboard.set_value("last_animation_finished", anim_name)

func _on_stealth_kill_area_body_entered(body: Node3D) -> void:
	if body == player:
		if get_health() > 0:
			player.set_stealth_kill_target(self)

func _on_stealth_kill_area_body_exited(body: Node3D) -> void:
	if body == player and player.get_stealth_kill_target() == self:
		player.set_stealth_kill_target(null)

func _on_pick_up_body_area_body_entered(body: Node3D) -> void:
	if body == player and get_health() <= 0:
		player.set_carry_body_target(self)

func _on_pick_up_body_area_body_exited(body: Node3D) -> void:
	if body == player and (player.get_carry_body_target() == self and not player.get_node("Blackboard").get_value("carry_body")):
		player.set_carry_body_target(null)
