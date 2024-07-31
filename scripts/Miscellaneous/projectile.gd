extends Node3D

## For generic tracer-style firearm projectile,
## e.g. for use with pistols, shotguns, automatic weapons etc.

var normalised_direction_vector: Vector3
var speed: float
var max_life_time_secs
var remaining_life_time_secs: float
var max_damage: float
var damage: float
var shooter_collision: CollisionShape3D

@export var projectile_tracer_ray_cast_3d: RayCast3D
@onready var player: CharacterBody3D = get_tree().get_first_node_in_group("player")


func _ready() -> void:
	look_at(global_position + normalised_direction_vector, Vector3.UP)

## Inherits key variables from node with spawned the projectile
## and assigns them to local variables
func set_up_variables(
		direction,
		own_collision_mesh,
		projectile_speed,
		projectile_life_secs,
		projectile_max_damage,
		) -> void:
	
	normalised_direction_vector -= direction
	speed = projectile_speed
	max_life_time_secs = projectile_life_secs
	remaining_life_time_secs = projectile_life_secs
	max_damage = projectile_max_damage
	shooter_collision = own_collision_mesh


func _physics_process(delta):
	var velocity = normalised_direction_vector * speed * delta
	position += velocity
	
	collision_detection()
	
	lifetime_and_self_termination(delta)


func collision_detection() -> void:
	var collision: Node3D
	if projectile_tracer_ray_cast_3d.is_colliding():
		collision = projectile_tracer_ray_cast_3d.get_collider()
		damage = damage_as_a_function_of_projectile_lifespan()
		if collision == shooter_collision:
			prints("projectile.gd:", shooter_collision, "collided with their own projectile")
			pass
		elif collision == player:
			player.track_health(damage)
			queue_free()
		elif collision.is_in_group("enemy"):
			collision.taken_hit(damage)
			queue_free()
		elif collision != null:
			queue_free()


func damage_as_a_function_of_projectile_lifespan() -> float:
	var percentage_projectile_force_remaining = \
			remaining_life_time_secs / max_life_time_secs
	damage = max_damage * percentage_projectile_force_remaining
	return damage


func lifetime_and_self_termination(delta) -> void:
	remaining_life_time_secs -= delta
	if remaining_life_time_secs <= 0:
		queue_free()
