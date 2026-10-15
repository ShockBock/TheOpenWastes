extends State

@export var collision_shape: CollisionShape3D
@export var death_sound: AudioStreamPlayer3D


func enter() -> void:
	super()
	death_sound.play()

	if npc.is_dead:
		return
	npc.is_dead = true
	collision_shape.queue_free()
	npc.died.emit()
