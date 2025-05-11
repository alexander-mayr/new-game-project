extends Control

@onready var player = get_tree().get_first_node_in_group("player_character")
var gradient = Gradient.new()

var meters = {}

func _ready() -> void:
	gradient.set_color(0, Color.GREEN)
	gradient.set_color(1, Color.RED)
	gradient.add_point(1 * 0.25, Color.GREEN_YELLOW)
	gradient.add_point(2 * 0.25, Color.YELLOW)
	gradient.add_point(3 * 0.25, Color.ORANGE)
	
func add_meter(guard):
	if guard in meters.keys():
		return

	var meter = preload("res://ui/detection_meter.tscn").instantiate()
	meters[guard] = meter
	add_child(meter)

func _process(delta: float) -> void:
	for guard in meters.keys():
		var v = Vector2(guard.global_position.x, guard.global_position.z)
		var w = Vector2(player.global_position.x, player.global_position.z)
		var c = Vector2(player.cam.global_position.x, player.cam.global_position.z)
		var cam_to_player = w - c
		var guard_to_player = w - v
		var a = cam_to_player.angle_to(guard_to_player)
		var meter = meters[guard]
		var p = get_viewport().get_visible_rect().size/2.0
		meter.global_position = p + Vector2(0, 600).rotated(a)
		meter.rotation = PI + a
		var value = guard.player_spotted_counter/1.5
		meter.modulate = gradient.sample(value)

		if guard.player_spotted_counter <= 0:
			remove_child(meter)
			meters.erase(guard)
