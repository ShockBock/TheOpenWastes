extends Node3D

## A tracer-style firearm projectile, used by pistols, shotguns, automatic
## weapons etc. Anything it hits that has a take_damage(amount) method takes
## damage; damage falls off over the projectile's lifetime.

@export var projectile_tracer_ray_cast_3d: RayCast3D

var direction: Vector3
var speed: float
var life_secs: float
var remaining_life_secs: float
var max_damage: float


## Called by the spawner before the projectile is added to the tree.
func set_up(
	travel_direction: Vector3,
	shooter: CollisionObject3D,
	projectile_speed: float,
	projectile_life_secs: float,
	projectile_max_damage: float,
) -> void:
	direction = travel_direction.normalized()
	speed = projectile_speed
	life_secs = projectile_life_secs
	remaining_life_secs = projectile_life_secs
	max_damage = projectile_max_damage
	# Never hit whoever fired it
	projectile_tracer_ray_cast_3d.add_exception(shooter)


func _ready() -> void:
	look_at(global_position + direction, Vector3.UP)


func _physics_process(delta: float) -> void:
	position += direction * speed * delta
	check_for_collision()

	remaining_life_secs -= delta
	if remaining_life_secs <= 0:
		queue_free()


func check_for_collision() -> void:
	if not projectile_tracer_ray_cast_3d.is_colliding():
		return
	var collider: Object = projectile_tracer_ray_cast_3d.get_collider()
	if collider != null and collider.has_method("take_damage"):
		collider.take_damage(current_damage())
	queue_free()


func current_damage() -> float:
	return max_damage * remaining_life_secs / life_secs
