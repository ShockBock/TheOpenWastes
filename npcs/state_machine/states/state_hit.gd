extends State

@export var pursue_state: State
@export var die_state: State
@export var hit_sound: AudioStreamPlayer3D

var hit_state_length: float


func enter() -> void:
	super()
	hit_state_length = npc.stats.hit_state_length
	subtract_damage()


func subtract_damage() -> void:
	npc.health -= npc.last_damage_taken
	if npc.health > 0:
		hit_sound.play()


func process_frame(delta: float) -> State:
	if npc.health <= 0:
		return die_state

	hit_state_length -= delta
	if hit_state_length <= 0:
		return pursue_state
	return null
