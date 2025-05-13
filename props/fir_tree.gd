extends Node3D

func _ready() -> void:
	get_node("0").hide()
	get_node("1").hide()
	get_node("2").hide()
	var c = str(randi_range(0, 2))
	print(c)
	get_node(c).show()
	rotation.y = randf_range(0, 2*PI)
	
