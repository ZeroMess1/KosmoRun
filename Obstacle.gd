extends Node3D

func _ready():
	add_to_group("obstacle")
	var area = $Area3D
	if area:
		area.add_to_group("obstacle")
