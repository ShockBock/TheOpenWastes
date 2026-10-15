extends State

@export var pursue_state: State
@export var die_state: State
@export var npc_data: Node

@export var hit_sound: AudioStreamPlayer3D

var hit_state_length: float


func enter():
	super()
	hit_state_length = npc_data.hit_state_length
	subtract_damage()


func subtract_damage() -> void:
	npc_data.health -= npc.last_damage_taken
	
	if npc_data.health > 0:
		hit_sound.play()


func process_frame(delta) -> State:
	if npc_data.health <= 0:
		return die_state
	
	hit_state_length -= delta
	if hit_state_length <= 0:
		return pursue_state
	
	return null
