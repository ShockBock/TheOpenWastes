extends State

@export var pursue_state: State
@export var die_state: State

@export var hit_sound: AudioStreamPlayer3D

var hit_state_length: float


func enter():
	super()
	hit_state_length = NPC.hit_state_length
	subtract_damage()


func subtract_damage() -> void:
	NPC.health -= NPC.last_damage_taken
	if NPC.health > 0:
		hit_sound.play()


func process_frame(delta) -> State:
	if NPC.health <= 0:
		return die_state
	
	hit_state_length -= delta
	if hit_state_length <= 0:
		return pursue_state
	
	return null
