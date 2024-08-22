extends Camera3D

var distance: float = 1.0

func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("left"):
		position.x += distance
	if Input.is_action_just_pressed("right"):
		position.x -= distance
	if Input.is_action_just_pressed("forward"):
		position.z += distance
	if Input.is_action_just_pressed("backward"):
		position.z -= distance
