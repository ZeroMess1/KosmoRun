extends Node3D

var collected: bool = false

func _ready():
	add_to_group("coin")
	var area = $Area3D
	if area:
		area.add_to_group("coin")

func _process(delta: float):
	rotation.y += delta * 3.0

func collect():
	if collected:
		return
	collected = true
	var tween = create_tween()
	tween.tween_property(self, "position:y", position.y + 2.0, 0.3)
	tween.parallel().tween_property(self, "scale", Vector3.ZERO, 0.3)
	tween.tween_callback(queue_free)
