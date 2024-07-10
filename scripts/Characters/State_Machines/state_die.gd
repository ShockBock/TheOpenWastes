extends State

@export var collision_shape : CollisionShape3D
@export var death_sound : AudioStreamPlayer3D

func enter():
	super()
	death_sound.play()

# Delete collision node, so characters and projectiles will no longer interact
	collision_shape.queue_free()

