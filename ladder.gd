extends Node3D

@onready var player = get_tree().get_first_node_in_group("player_character")

func ladder_look_dir():
	return ($EntryPoint.global_position.direction_to($Aux.global_position))

func height():
	return $UpperEntryArea.global_position.y - $LowerEntryArea.global_position.y

func _on_lower_entry_area_area_entered(area: Area3D) -> void:
	if area.has_meta("feet_area"):
		player.set_ladder_entry_area($LowerEntryArea)

func _on_lower_entry_area_area_exited(area: Area3D) -> void:
	if area.has_meta("feet_area") and player.get_ladder_entry_area() == $LowerEntryArea:
		player.set_ladder_entry_area(null)

func _on_upper_entry_area_area_entered(area: Area3D) -> void:
	if area.has_meta("feet_area"):
		player.set_ladder_entry_area($UpperEntryArea)

func _on_upper_entry_area_area_exited(area: Area3D) -> void:
	if area.has_meta("feet_area") and player.get_ladder_entry_area() == $UpperEntryArea:
		player.set_ladder_entry_area(null)
