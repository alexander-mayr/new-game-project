extends CharacterBody3D

var input_vector = Vector2.ZERO
var sneaking = false
var prone = false
var sneak_button_is_pressed = false
var time_sneak_button_pressed = 0.0
var punching = false
var aiming = false
var jumping = false
var stealth_kill = false
var stealth_kill_target = null
var stop_input = false
var target_in_reticle = false
var can_hit_target = false
var movement_blend_strength = -1.0
var cut_object = false
var cut_object_target = null
var working_on_device = false
var carry_body_target = null

const MIN_INPUT_LENGTH = 0.2

var center_in_high_grass = false
var front_in_high_grass = false
var back_in_high_grass = false

@onready var cam = get_tree().get_first_node_in_group("camera")

func _process(delta: float) -> void:
	if carry_body:
		var bone = $AuxScene/Node/Skeleton3D.find_bone("mixamorigHips")
		var pos = $AuxScene/Node/Skeleton3D.get_bone_pose_position(bone)
		$CarryBodyMeshPoint.position = pos - Vector3(0, 0.91, 0)

	input_vector = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	
	if not stop_input:
		_handle_input(delta)

	_set_animation_blends()
	_set_reticle()
	_set_action_tooltip()

func is_hidden():
	return center_in_high_grass and front_in_high_grass and back_in_high_grass

func _lerp_blend(blend_name, target, t = 0.1):
	var param_string = "parameters/" + blend_name + "/blend_amount"
	var param_value = float($AnimationTree.get(param_string))
	$AnimationTree.set(param_string, lerp(param_value, target, t))

func _set_animation_blends():
	_lerp_stance()
	_lerp_falling()
	_lerp_movement_strength()
	_lerp_stealth_kill()
	_lerp_movement_inputs()
	_lerp_working_on_device()
	_lerp_carry_body()
	
	if aiming:
		_lerp_aiming_blends(1.0)
	else:
		_lerp_aiming_blends(0.0)

func _lerp_carry_body():
	if carry_body:
		_lerp_blend("CarryBody", 1.0)
	else:
		_lerp_blend("CarryBody", 0.0)

func _lerp_working_on_device():
	if working_on_device:
		_lerp_blend("WorkingOnDevice", 1.0)
	else:
		_lerp_blend("WorkingOnDevice", .0)

func _lerp_movement_inputs():
	if input_vector.length() > 0:
		if abs(input_vector.x) > abs(input_vector.y):
			if input_vector.x > 0:
				_lerp_aiming_strafe_blends(1.0)
				_set_aiming_movement_time_scales(1.0)
			elif input_vector.x < 0:
				_lerp_aiming_strafe_blends(1.0)
				_set_aiming_movement_time_scales(-1.0)
		elif abs(input_vector.y) > abs(input_vector.x):
			if input_vector.y > 0:
				_lerp_aiming_strafe_blends(0.0)
				_set_aiming_movement_time_scales(-1.0)
			elif input_vector.y < 0:
				_lerp_aiming_strafe_blends(0.0)
				_set_aiming_movement_time_scales(1.0)

func _lerp_stance():
	if sneaking:
		_lerp_blend("Stance", 0.0)
	elif prone:
		_lerp_blend("Stance", -1.0)
	else:
		_lerp_blend("Stance", 1.0)

func _lerp_stealth_kill():
	if stealth_kill:
		_lerp_blend("StealthKill", 1.0)
		$AuxScene.position.z = -1.245 * $AnimationTree.get("parameters/StealthKill/blend_amount")
	else:
		_lerp_blend("StealthKill", 0.0)
		$AuxScene.position.z = -1.245 * $AnimationTree.get("parameters/StealthKill/blend_amount")

func _lerp_movement_strength():
	if velocity.length() == 0.0:
		movement_blend_strength = -1.0
		if carry_body:
			movement_blend_strength = 0.0
	elif velocity.length() > 2.0:
		if carry_body:
			movement_blend_strength = 0.5
		movement_blend_strength = 1.0
	else:
		if carry_body:
			movement_blend_strength = 1.0
		movement_blend_strength = 1.0

	if aiming and movement_blend_strength == 1.0:
		movement_blend_strength = 0.0

	_lerp_blend("SneakMovement", movement_blend_strength)
	_lerp_blend("ProneMovement", movement_blend_strength)
	_lerp_blend("DefaultMovement", movement_blend_strength)
	_lerp_blend("CarryWalking", movement_blend_strength)

func _lerp_falling():
	if is_on_floor():
		_lerp_blend("Falling", 0.0)
	else:
		_lerp_blend("Falling", 1.0)

func _lerp_aiming_strafe_blends(v):
	_lerp_blend("AimingStrafe", v)
	_lerp_blend("AimingStrafeSneak", v)

func _lerp_aiming_blends(v):
	_lerp_blend("AimingIdle", v)
	_lerp_blend("AimingIdleSneak", v)
	_lerp_blend("AimingWalking", v)
	_lerp_blend("AimingRunning", v)
	_lerp_blend("AimingWalkingSneak", v)

func _set_aiming_movement_time_scales(v):
	$AnimationTree.set("parameters/AimingMovementTimeScale/scale", v)
	$AnimationTree.set("parameters/AimingMovementSneakTimeScale/scale", v)

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
	$JumpTimer.start(0.3)

func _start_stealth_kill():
	global_position = stealth_kill_target.get_node("StealthKillPoint").global_position
	$AnimationTree.set("parameters/StealthKillTimeSeek/seek_request", 0.0)
	rotation.y = stealth_kill_target.rotation.y
	$StealthKillTimer.start(5.9333)
	stealth_kill = true
	stealth_kill_target.start_getting_stealth_killed()

func _set_action_tooltip():
	if stealth_kill_target:
		get_node("/root/World").set_action_tooltip("[R1] Stealth Kill")
	elif cut_object:
		get_node("/root/World").set_action_tooltip("[Square] Cut " + cut_object_target.name)
	elif carry_body_target:
		get_node("/root/World").set_action_tooltip("[Square] Carry body")
	else:
		get_node("/root/World").clear_action_tooltip()

func _on_animation_tree_animation_finished(anim_name: StringName) -> void:
	if anim_name == "WorkingOnDevice":
		working_on_device = false
		cut_object_target.cut_open()
		cut_object_target = null
		cut_object = false

var carry_body = false

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
			working_on_device = true
		elif carry_body_target != null:
			carry_body = true
			carry_body_target.get_parent().remove_child(carry_body_target)
			$CarryBodyMeshPoint/CarryingBodyMesh.show()

	if Input.is_action_just_pressed("toggle_sneak"):
		sneak_button_is_pressed = true

	if Input.is_action_just_pressed("fire") and aiming:
		_fire_gun()

	if Input.is_action_just_pressed("jump"):
		_start_jump()

	if Input.is_action_just_pressed("stealth_kill"):
		if stealth_kill_target:
			_start_stealth_kill()
			stop_input = true

	if Input.is_action_just_released("toggle_sneak"):
		if sneak_button_is_pressed:
			if prone:
				prone = false
				sneaking = true
				_set_sneak_collision()
			else:
				sneaking = not sneaking
				
				if sneaking:
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
			prone = true
			sneaking = false
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

	#print(result)
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
	elif sneaking:
		speed_factor = 0.5
	elif prone:
		speed_factor = 0.25
	elif carry_body:
		speed_factor = 0.25

	velocity.x = vec.y * 6 * input_vector.length() * speed_factor
	velocity.z = -vec.x * 6 * input_vector.length() * speed_factor
	rotation.y = Vector2(velocity.x, velocity.z).angle_to(Vector2(0, 1))

func _handle_aim_movement():
	velocity = Vector3(0, 0, -1).rotated(Vector3.UP, rotation.y) * 5 * input_vector.y
	velocity += Vector3(-1, 0, 0).rotated(Vector3.UP, rotation.y) * 5 * input_vector.x

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= 15 * delta

	if aiming:
		_check_aim_target()

	if input_vector.length() > MIN_INPUT_LENGTH and not stop_input:
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

func _on_stealth_kill_timer_timeout() -> void:
	stealth_kill = false
	stop_input = false































#func _set_animation_blends():
	#if stealth_kill:
		#_lerp_anim_tree_param("StealthKillBlend/blend_amount", 1.0)
		#$AuxScene.position.z = -1.245 * $AnimationTree.get("parameters/StealthKillBlend/blend_amount")
	#else:
		#_lerp_anim_tree_param("StealthKillBlend/blend_amount", 0.0)
		#$AuxScene.position.z = -1.245 * $AnimationTree.get("parameters/StealthKillBlend/blend_amount")
		#
	#if jumping:
		#_lerp_anim_tree_param("JumpBlend/blend_amount", 1.0)
	#else:
		#_lerp_anim_tree_param("JumpBlend/blend_amount", 0.0)
#
	#if not is_on_floor():
		#_lerp_anim_tree_param("FallingBlend/blend_amount", 1.0)
#
	#if is_on_floor():
		#_lerp_anim_tree_param("FallingBlend/blend_amount", 0.0)
#
		#if aiming:
			#if sneaking:
				#_lerp_anim_tree_param("AimSneakBlend/blend_amount", 1.0)
			#else:
				#_lerp_anim_tree_param("AimBlend/blend_amount", 1.0)
#
			#if input_vector.x != 0 or input_vector.y != 0:
				#if abs(input_vector.x) > abs(input_vector.y):
					#if input_vector.x > 0:
						#_lerp_anim_tree_param("AimStrafeRightBlend/blend_amount", 1.0)
						#_lerp_anim_tree_param("AimStrafeLeftBlend/blend_amount", 0.0)
					#elif input_vector.x < 0:
						#_lerp_anim_tree_param("AimStrafeLeftBlend/blend_amount", 1.0)
						#_lerp_anim_tree_param("AimStrafeRightBlend/blend_amount", 0.0)
				#else:
					#if input_vector.y < 0:
						#_lerp_anim_tree_param("AimWalkingBlend/blend_amount", 1.0)
						#_lerp_anim_tree_param("AimWalkingBackBlend/blend_amount", 0.0)
						#_lerp_anim_tree_param("AimStrafeRightBlend/blend_amount", 0.0)
						#_lerp_anim_tree_param("AimStrafeLeftBlend/blend_amount", 0.0)
					#elif input_vector.y > 0:
						#_lerp_anim_tree_param("AimWalkingBlend/blend_amount", 0.0)
						#_lerp_anim_tree_param("AimStrafeRightBlend/blend_amount", 0.0)
						#_lerp_anim_tree_param("AimStrafeLeftBlend/blend_amount", 0.0)
						#_lerp_anim_tree_param("AimWalkingBackBlend/blend_amount", 1.0)
			#else:
				#_lerp_anim_tree_param("AimWalkingBlend/blend_amount", 0.0)
				#_lerp_anim_tree_param("AimWalkingBackBlend/blend_amount", 0.0)
				#_lerp_anim_tree_param("AimStrafeRightBlend/blend_amount", 0.0)
				#_lerp_anim_tree_param("AimStrafeLeftBlend/blend_amount", 0.0)
		#else:
			#_lerp_anim_tree_param("AimSneakBlend/blend_amount", 0.0)
			#_lerp_anim_tree_param("AimBlend/blend_amount", 0.0)
			#_lerp_anim_tree_param("AimWalkingBlend/blend_amount", 0.0)
#
		#if prone:
			#_lerp_anim_tree_param("ProneBlend/blend_amount", 1.0, 0.05)
			#
			#if input_vector.length() > 0:
				#_lerp_anim_tree_param("ProneCrawlingBlend/blend_amount", 1.0)
			#else:
				#_lerp_anim_tree_param("ProneCrawlingBlend/blend_amount", 0.0)
		#else:
			#_lerp_anim_tree_param("ProneCrawlingBlend/blend_amount", 0.0)
			#_lerp_anim_tree_param("ProneBlend/blend_amount", 0.0, 0.05)
		#
		#if sneaking:
			#_lerp_anim_tree_param("SneakBlend/blend_amount", 1.0)
			#_lerp_anim_tree_param("WalkingBlend/blend_amount", 0.0)
			#_lerp_anim_tree_param("RunningBlend/blend_amount", 0.0)
#
			#if input_vector.length() > 0:
				#_lerp_anim_tree_param("SneakWalkingBlend/blend_amount", 1.0)
			#else:
				#_lerp_anim_tree_param("SneakWalkingBlend/blend_amount", 0.0)
		#else:
			#_lerp_anim_tree_param("SneakBlend/blend_amount", 0.0)
			#_lerp_anim_tree_param("SneakWalkingBlend/blend_amount", 0.0)
#
			#if input_vector.length() > 0:
				#if input_vector.length() < 0.5:
					#_lerp_anim_tree_param("WalkingBlend/blend_amount", 1.0)
					#_lerp_anim_tree_param("RunningBlend/blend_amount", 0.0)
				#else:
					#_lerp_anim_tree_param("WalkingBlend/blend_amount", 0.0)
					#_lerp_anim_tree_param("RunningBlend/blend_amount", 1.0)
			#else:
				#_lerp_anim_tree_param("WalkingBlend/blend_amount", 0.0)
				#_lerp_anim_tree_param("RunningBlend/blend_amount", 0.0)
