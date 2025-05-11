extends Area3D

@onready var player = get_tree().get_first_node_in_group("player_character")

func _on_area_entered(area: Area3D) -> void:
	if area.has_meta("high_grass_detection"):
		if area.has_meta("center"):
			player.center_in_high_grass = true
		elif area.has_meta("front"):
			player.front_in_high_grass = true
		elif area.has_meta("back"):
			player.back_in_high_grass = true

func _on_area_exited(area: Area3D) -> void:
	if area.has_meta("high_grass_detection"):
		if area.has_meta("center"):
			player.center_in_high_grass = false
		elif area.has_meta("front"):
			player.front_in_high_grass = false
		elif area.has_meta("back"):
			player.back_in_high_grass = false
