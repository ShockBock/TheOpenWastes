extends Node3D

var normalised_direction_vector : Vector3
var speed : float
var life_secs : float
var max_damage : float
var shooter_collision : CollisionShape3D

@onready var projectile_tracer_ray_cast_3d = %Projectile_tracer_RayCast3D
@onready var player : CharacterBody3D = get_tree().get_first_node_in_group("player")


func _ready() -> void:
	look_at(global_position + normalised_direction_vector, Vector3.UP)


func set_up_variables(direction, projectile_speed,
		projectile_life_secs, projectile_max_damage, character_collision):
	# Inherits key variables from node with spawned the projectile
	normalised_direction_vector -= direction
	speed = projectile_speed
	life_secs = projectile_life_secs
	max_damage = projectile_max_damage
	shooter_collision = character_collision


func _physics_process(delta):
	var velocity = normalised_direction_vector * speed * delta
	position += velocity
	
	collision_detection()
	
	lifetime_and_self_termination(delta)


func collision_detection() -> void:
	var collision : Node3D
	if projectile_tracer_ray_cast_3d.is_colliding():
		collision = projectile_tracer_ray_cast_3d.get_collider()
		print(collision)
	if collision == shooter_collision:
		print("I done shot myself lol")
		pass
	elif collision == player:
		player.health_tracker(max_damage)
		queue_free()
	elif collision != null:
		queue_free()


func lifetime_and_self_termination(delta) -> void:
	life_secs -= delta
	if life_secs <= 0:
		queue_free()
