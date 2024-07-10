extends State

@export var pursue_state: State
@export var die_state: State

@export var hit_sound : AudioStreamPlayer3D

var hit_state_length : float


func enter():
	super()
	hit_state_length = parent.hit_state_length
	hit_sound.play()
	subtract_damage()

func subtract_damage() -> void:
	parent.health -= parent.last_damage_taken


func process_frame(delta) -> State:
	if parent.health <= 0:
		return die_state
	
	hit_state_length -= delta
	if hit_state_length <= 0:
		return pursue_state
	
	return null
