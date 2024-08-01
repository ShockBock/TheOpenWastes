extends State

@export var collision_shape : CollisionShape3D
@export var death_sound : AudioStreamPlayer3D
@export var npc_data: Node

func enter():
	super()
	death_sound.play()

# Delete collision node, so characters and projectiles will no longer interact
	if npc.is_dead == true:
		return
	else:
		npc.is_dead = true
		collision_shape.queue_free()
