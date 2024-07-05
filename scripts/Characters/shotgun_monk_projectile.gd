extends Node3D

var normalised_direction_vector : Vector3
var speed : float
var life_secs : float
var shooter_collision : CollisionShape3D
@onready var projectile_tracer_ray_cast_3d = %Projectile_tracer_RayCast3D
@onready var player : CharacterBody3D = get_tree().get_first_node_in_group("player")
#@onready var player_collision = player.get_node("Player_CollisionShape3D")

func _ready() -> void:
	look_at(global_position + normalised_direction_vector, Vector3.UP)


func set_up_variables(direction, projectile_speed,
		projectile_life_secs, character_collision):
	# Inherits a direction for the pellet to travel,
	# and its speed, from, e.g. shotgun_monk_buckshot_spawner.gd
	normalised_direction_vector -= direction
	speed = projectile_speed
	shooter_collision = character_collision
	life_secs = projectile_life_secs


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
	elif collision == player:
		print("I done shot the player lol")
	elif collision != null:
		print("I done hit summat!")


func lifetime_and_self_termination(delta) -> void:
	life_secs -= delta
	if life_secs <= 0:
		queue_free()
