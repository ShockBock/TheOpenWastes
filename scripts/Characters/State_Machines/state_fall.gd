extends State

@export
var follow_state: State

func process_physics(delta: float) -> State:
	fall(delta)
	if parent.is_on_floor():
		return follow_state
	return null

func fall(delta) -> void:
	var velocity = parent.velocity
	velocity.y -= gravity * delta
	
	parent.velocity = velocity
	parent.move_and_slide()  # Move the character
