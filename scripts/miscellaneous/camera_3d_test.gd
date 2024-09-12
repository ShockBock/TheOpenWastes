extends Camera3D

## Debugging Camera3D.
##
## Basic code, just to get a port-a-camera into the scene. [br]
## At some point, adding mouse look and linear interpolation to the key presses
## would probably make it more pleasant to use.
##
## @experimental


var distance: float = 1.0
var rotation_rate: float = 0.2

func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_key_pressed(KEY_A): # left.
		position -= transform.basis.x * distance
	if Input.is_key_pressed(KEY_D): # right
		position += transform.basis.x * distance
	if Input.is_key_pressed(KEY_W): # forward.
		var direction = -transform.basis.z
		direction.y = 0 # Ensure no vertical movement.
		direction = direction.normalized() # Normalize to keep consistent speed.
		position += direction * distance
	if Input.is_key_pressed(KEY_S): # backward.
		var direction = +transform.basis.z
		direction.y = 0 # Ensure no vertical movement.
		direction = direction.normalized() # Normalize to keep consistent speed.
		position += direction * distance
	if Input.is_key_pressed(KEY_Q): # tilt camera up.
		rotation.x += rotation_rate
	if Input.is_key_pressed(KEY_E): # tilt camera down.
		rotation.x -= rotation_rate
	
	if Input.is_key_pressed(KEY_UP):
		position.y += distance
	if Input.is_key_pressed(KEY_DOWN):
		position.y -= distance
	if Input.is_key_pressed(KEY_LEFT):
		rotation.y += rotation_rate
	if Input.is_key_pressed(KEY_RIGHT):
		rotation.y -= rotation_rate
	
