extends StaticBody3D

@onready var player = get_tree().get_first_node_in_group("player_character")

func cut_open():
	$Model/WireLower.hide()
	$CollisionShape3D.disabled = true
	$CollisionShapeCutOpen.disabled = false

func _on_cut_area_body_entered(body: Node3D) -> void:
	if body == player:
		player.cut_object = true
		player.cut_object_target = self

func _on_cut_area_body_exited(body: Node3D) -> void:
	if body == player and player.cut_object_target == self:
		player.cut_object = false
		player.cut_object_target = null
