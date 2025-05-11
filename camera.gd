extends Camera3D

var free_cam_ang = PI/2
var aim_cam_ang = null
var free_cam_y = 1.0
var input_vector = Vector2.ZERO
var free_cam_distance = 5.0

@onready var player = get_tree().get_first_node_in_group("player_character")

func _process(delta: float) -> void:
	input_vector = Input.get_vector("camera_left", "camera_right", "camera_up", "camera_down")

	if player.aiming:
		_handle_aim_cam(delta)
	else:
		_handle_free_cam(delta)

func _handle_aim_cam(delta):
	global_position = player.global_position + (Vector3(-0.5, 0, -1)).rotated(Vector3.UP, player.rotation.y) + Vector3(0, 1.5, 0)
	player.rotation.y -= input_vector.x * delta * 1.5
	aim_cam_ang += input_vector.y * delta * 1.25

	if aim_cam_ang > deg_to_rad(30):
		aim_cam_ang = deg_to_rad(30)
	elif aim_cam_ang < -deg_to_rad(30):
		aim_cam_ang = -deg_to_rad(30)

	var v = Vector3(0, 0, 1)
	v = v.rotated(Vector3.LEFT, aim_cam_ang)
	v = v.rotated(Vector3.UP, player.rotation.y)
	look_at(global_position + v)

func switch_to_aiming():
	aim_cam_ang = rotation.x

func switch_to_free():
	aim_cam_ang = null
	free_cam_ang = -(player.rotation.y + PI/2)

func _handle_free_cam(delta):
	if input_vector.length() > 0.1:
		if abs(input_vector.x) > 0.4:
			free_cam_ang += input_vector.x * 3 * delta

		if abs(input_vector.y) > 0.4:
			if $RayCast3D.get_collider() == null or input_vector.y < 0:
				free_cam_y -= input_vector.y * 5 * delta
				if free_cam_distance < 5.0 and input_vector.y < 0:
					free_cam_distance -= input_vector.y * delta * 5

				if free_cam_y > 5.0:
					free_cam_y = 5.0
			elif $RayCast3D.get_collider() != null and $RayCast3D.get_collision_point().distance_to($RayCast3D.global_position) >= 0.5:
				var k = 4
				free_cam_distance -= delta * k
				free_cam_y -= delta * k

	var x = free_cam_distance * cos(free_cam_ang)
	var z = free_cam_distance * sin(free_cam_ang)
	var vec = Vector3(x, free_cam_y, z)
	global_position = player.global_position + vec + Vector3(0, 1, 0)
	look_at(player.global_position + Vector3(0, 2, 0))
