extends Node3D

@onready var next_point = get_node(next_point_path)
@export var next_point_path = NodePath()
@export var spawn_guard = false
