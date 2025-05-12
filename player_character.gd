extends CharacterBody3D

var input_vector = Vector2.ZERO

var sneak_button_is_pressed = false
var time_sneak_button_pressed = 0.0
var aiming = false
var jumping = false

var target_in_reticle = false

var can_hit_target = false
var cut_object = false
var cut_object_target = null

const MIN_INPUT_LENGTH = 0.2

var center_in_high_grass = false
var front_in_high_grass = false
var back_in_high_grass = false

@onready var cam = get_tree().get_first_node_in_group("camera")

func in_default_stance():
	return not ($Blackboard.get_value("prone") or $Blackboard.get_value("sneaking") or $Blackboard.get_value("carry_body"))

func in_prone_stance():
	return $Blackboard.get_value("prone") == true

func in_sneak_stance():
	return $Blackboard.get_value("sneaking") == true

func in_carry_stance():
	return $Blackboard.get_value("carry_body")

func has_stealth_kill_target():
	return $Blackboard.get_value("stealth_kill_target") != null

func set_stealth_kill_target(target):
	$Blackboard.set_value("stealth_kill_target", target)

func get_stealth_kill_target():
	return $Blackboard.get_value("stealth_kill_target")

func get_carry_body_target():
	return $Blackboard.get_value("carry_body_target")

func set_carry_body_target(target):
	$Blackboard.set_value("carry_body_target", target)

func set_ladder_entry_area(ladder):
	$Blackboard.set_value("ladder_entry_area", ladder)

func get_ladder_entry_area():
	return $Blackboard.get_value("ladder_entry_area")

func on_ladder():
	return $Blackboard.get_value("on_ladder") == true

func set_ladder(ladder):
	$Blackboard.set_value("ladder", ladder)

func get_ladder():
	return $Blackboard.get_value("ladder")

func get_ladder_pos():
	return $Blackboard.get_value("ladder_pos")

func set_ladder_pos(pos):
	$Blackboard.set_value("ladder_pos", pos)

func _process(delta: float) -> void:
	#return

	$AnimationTree.active = true

	if in_carry_stance() and not $Blackboard.get_value("put_down_body"):
		var bone = $AuxScene/Node/Skeleton3D.find_bone("mixamorigHips")
		var pos = $AuxScene/Node/Skeleton3D.get_bone_pose_position(bone)
		$CarryBodyMeshPoint.position = pos - Vector3(0, 0.91, 0)

	input_vector = Input.get_vector("move_left", "move_right", "move_forward", "move_back")

	if not _stop_input():
		_handle_input(delta)

	_set_reticle()
	_set_action_tooltip()

	var moving = abs(velocity.x) > 0 or abs(velocity.y) > 0
	var running = in_default_stance() and velocity.length() > 5

	if on_ladder():
		$Blackboard.set_value("ladder_movement", -input_vector.y)

	$Blackboard.set_value("moving", moving)
	$Blackboard.set_value("running", running)
	$Blackboard.set_value("aiming", aiming)
	$Blackboard.set_value("input_vector", input_vector)
	
func is_hidden():
	return center_in_high_grass and front_in_high_grass and back_in_high_grass

func lerp_to_stance(value, weight = 0.1):
	var blend_position = $AnimationTree.get("parameters/BlendSpace1D/blend_position")
	blend_position = lerp(blend_position, value, weight)
	$AnimationTree.set("parameters/BlendSpace1D/blend_position", blend_position)

func lerp_param(param, target, weight = 0.1):
	if $AnimationTree.get(param) == null:
		return

	var v = float($AnimationTree.get(param))
	v = lerp(v, target, weight)
	$AnimationTree.set(param, v)

func lerp_param_vec(param, target, weight = 0.1):
	var v = $AnimationTree.get(param)
	v = v.lerp(target, weight)
	$AnimationTree.set(param, v)

func _switch_to_aiming():
	var v = cam.global_position.direction_to(global_position)
	var w = Vector2(v.x, v.z)
	var a = w.angle_to(Vector2(0, 1))
	rotation.y = a
	cam.switch_to_aiming()

func _start_jump():
	$AnimationTree.set("parameters/JumpTimeSeek/seek_request", 0.5)
	jumping = true
	velocity.y = 6

func _start_stealth_kill():
	global_position = get_stealth_kill_target().get_node("StealthKillPoint").global_position
	$AnimationTree.set("parameters/BlendSpace1D/0/StealthKillTimeSeek/seek_request", 0.0)
	rotation.y = get_stealth_kill_target().rotation.y
	$Blackboard.set_value("stealth_kill", true)
	get_stealth_kill_target().start_getting_stealth_killed()

func _set_action_tooltip():
	if has_stealth_kill_target() and get_stealth_kill_target().get_health() > 0 and not $Blackboard.get("stealth_kill"):
		get_node("/root/World").set_action_tooltip("[R1] Stealth Kill")
	elif cut_object:
		get_node("/root/World").set_action_tooltip("[Square] Cut " + cut_object_target.name)
	elif $Blackboard.get_value("carry_body_target") and not in_carry_stance():
		get_node("/root/World").set_action_tooltip("[Square] Carry body")
	elif in_carry_stance():
		get_node("/root/World").set_action_tooltip("[Square] Put down body")
	elif get_ladder_entry_area() != null:
		get_node("/root/World").set_action_tooltip("[Square] Climb ladder")
	else:
		get_node("/root/World").clear_action_tooltip()

func _on_animation_tree_animation_finished(anim_name: StringName) -> void:
	$Blackboard.set_value("last_animation_finished", anim_name)

	if anim_name == "WorkingOnDevice" and cut_object:
		$Blackboard.set_value("working_on_device", false)
		cut_object_target.cut_open()
		cut_object_target = null
		cut_object = false

func _handle_input(delta):
	if Input.is_action_just_released("aim"):
		aiming = not aiming
		if aiming:
			_switch_to_aiming()
		else:
			cam.switch_to_free()

	if Input.is_action_just_pressed("interact"):
		if cut_object:
			$AnimationTree.set("parameters/WorkingOnDeviceTimeSeek/seek_request", 0.0)
			$Blackboard.set_value("working_on_device", true)
		elif get_carry_body_target() != null and not in_carry_stance():
			$Blackboard.set_value("pick_up_body", true)
			$AnimationTree.set("parameters/BlendSpace1D/0/PickBodyUpTimeSeek/seek_request", 0.0)
		elif in_carry_stance() == true:
			$AnimationTree.set("parameters/BlendSpace1D/3/PutBodyDownTimeSeek/seek_request", 0.0)
			$Blackboard.set_value("put_down_body", true)
		elif get_ladder_entry_area() != null:
			if get_ladder_entry_area().has_meta("lower"):
				$AnimationTree.set("parameters/BlendSpace1D/0/LeaveLadderUpperTimeSeek/seek_request", 0.0)
				$AnimationTree.set("parameters/BlendSpace1D/0/LeaveLadderUpperTimeScale/scale", 1.0)
				$Blackboard.set_value("climb_ladder", true)
				set_ladder(get_ladder_entry_area().get_parent())
				set_ladder_pos(0)
				look_at(global_position - get_ladder().ladder_look_dir())
				$AnimationTree.set("parameters/BlendSpace1D/0/FreeMovement/blend_amount", 0.0)
			else:
				$AnimationTree.set("parameters/BlendSpace1D/0/LeaveLadderUpperTimeSeek/seek_request", 2.5)
				$AnimationTree.set("parameters/BlendSpace1D/0/LeaveLadderUpperTimeScale/scale", -1.0)
				$Blackboard.set_value("enter_ladder_upper", true)
				set_ladder(get_ladder_entry_area().get_parent())
				set_ladder_pos(get_ladder().height() - 1)
				look_at(global_position - get_ladder().ladder_look_dir())
				$AnimationTree.set("parameters/BlendSpace1D/0/FreeMovement/blend_amount", 0.0)

	if Input.is_action_just_pressed("toggle_sneak"):
		sneak_button_is_pressed = true

	if Input.is_action_just_pressed("fire") and aiming:
		_fire_gun()

	if Input.is_action_just_pressed("jump"):
		_start_jump()

	if Input.is_action_just_pressed("stealth_kill"):
		if has_stealth_kill_target():
			_start_stealth_kill()

	if Input.is_action_just_released("toggle_sneak"):
		if sneak_button_is_pressed:
			if in_prone_stance():
				$Blackboard.set_value("prone", false)
				$Blackboard.set_value("sneaking", true)
				_set_sneak_collision()
			else:
				$Blackboard.set_value("sneaking",not $Blackboard.get_value("sneaking"))
				
				if in_sneak_stance():
					_set_sneak_collision()
				else:
					_set_default_collision()

			sneak_button_is_pressed = false
			time_sneak_button_pressed = 0.0

	if sneak_button_is_pressed:
		time_sneak_button_pressed += delta

		if time_sneak_button_pressed >= 1.0:
			sneak_button_is_pressed = false
			time_sneak_button_pressed = 0.0
			$Blackboard.set_value("prone", true)
			$Blackboard.set_value("sneaking", true)
			_set_prone_collision()

func _set_reticle():
	if target_in_reticle != null:
		if can_hit_target:
			get_node("/root/World/CanvasLayer/Reticle").modulate = Color.RED
		else:
			get_node("/root/World/CanvasLayer/Reticle").modulate = Color.WHITE_SMOKE
	else:
		get_node("/root/World/CanvasLayer/Reticle").modulate = Color.BLACK

func _set_sneak_collision():
	$CollisionShape3D.disabled = true
	$CollisionShapeProne.disabled = true
	$CollisionShapeSneaking.disabled = false

func _set_prone_collision():
	$CollisionShape3D.disabled = true
	$CollisionShapeProne.disabled = false
	$CollisionShapeSneaking.disabled = true

func _set_default_collision():
	$CollisionShape3D.disabled = false
	$CollisionShapeProne.disabled = true
	$CollisionShapeSneaking.disabled = true

func _fire_gun():
	$AudioStreamPlayer.play()

	if target_in_reticle != null and can_hit_target:
		var target_blackboard = target_in_reticle.get_parent().get_parent().get_node("Blackboard")
		var target = target_in_reticle.get_parent().get_parent()

		if target_in_reticle.has_meta("hitbox_head"):
			target.get_hit_head(1)
		elif target_in_reticle.has_meta("hitbox_front"):
			target.get_hit_front(1)
		elif target_in_reticle.has_meta("hitbox_left"):
			target.get_hit_left(1)
		elif target_in_reticle.has_meta("hitbox_right"):
			target.get_hit_right(1)
		elif target_in_reticle.has_meta("hitbox_back"):
			target.get_hit_back(1)

func is_hitbox(obj):
	return obj is Area3D and obj.has_meta("hitbox")

func _check_aim_target():
	var p = get_viewport().get_visible_rect().size/2.0
	var from = cam.project_ray_origin(p)
	var to = from + cam.project_ray_normal(p) * 1000
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(from, to, 2, [self])
	query.collide_with_areas = true
	query.collide_with_bodies = true
	var result = space_state.intersect_ray(query)

	if result == {}:
		target_in_reticle = null
	else:
		if is_hitbox(result["collider"]):
			target_in_reticle = result["collider"]
			space_state = get_world_3d().direct_space_state
			var q = PhysicsRayQueryParameters3D.create($GunPoint.global_position, result["position"] + ($GunPoint.global_position.direction_to(result["position"])), 2, [self])
			q.collide_with_areas = true
			q.collide_with_bodies = true
			var r = space_state.intersect_ray(q)

			if r != {} and r["collider"] == target_in_reticle:
				can_hit_target = true
			else:
				can_hit_target = false
		else:
			target_in_reticle = null
			can_hit_target = false

func _handle_free_movement():
	var vec = input_vector.rotated(cam.free_cam_ang)
	var speed_factor = 1.0

	if not is_on_floor():
		speed_factor = 0.75
	elif in_sneak_stance():
		speed_factor = 0.5
	elif in_prone_stance():
		speed_factor = 0.25
	elif in_carry_stance():
		speed_factor = 0.25

	velocity.x = vec.y * 6 * input_vector.length() * speed_factor
	velocity.z = -vec.x * 6 * input_vector.length() * speed_factor
	rotation.y = Vector2(velocity.x, velocity.z).angle_to(Vector2(0, 1))

func _handle_aim_movement():
	velocity = Vector3(0, 0, -1).rotated(Vector3.UP, rotation.y) * 5 * input_vector.y
	velocity += Vector3(-1, 0, 0).rotated(Vector3.UP, rotation.y) * 5 * input_vector.x

func _stop_input():
	return $Blackboard.get_value("stealth_kill") or $Blackboard.get_value("pick_up_body")

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= 15 * delta

	if on_ladder():
		global_position = get_ladder().get_node("EntryPoint").global_position
		set_ladder_pos(get_ladder_pos() - input_vector.y * delta)

		if get_ladder_pos() < 0:
			set_ladder_pos(0)
			$Blackboard.set_value("leave_ladder_lower", true)
		elif get_ladder_pos() > get_ladder().height() - 1.65:
			set_ladder_pos(get_ladder().height() - 1.65)
			$Blackboard.set_value("leave_ladder_upper", true)

		global_position.y += get_ladder_pos()
		return

	if aiming:
		_check_aim_target()

	if input_vector.length() > MIN_INPUT_LENGTH and not _stop_input():
		if aiming:
			_handle_aim_movement()
		else:
			_handle_free_movement()
	else:
		velocity.x = 0
		velocity.z = 0

	move_and_slide()

func _on_jump_timer_timeout() -> void:
	jumping = false
