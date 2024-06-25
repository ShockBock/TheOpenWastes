extends CharacterBody3D

@onready var animated_sprite_3d : AnimatedSprite3D = $AnimatedSprite3D
@onready var enemy_shoot_ray : RayCast3D = $Enemy_shoot_ray
@onready var navigation : NavigationAgent3D = $NavigationAgent3D
@onready var player : CharacterBody3D = get_tree().get_first_node_in_group("player")

@export var move_speed : float = 2.0
@export var attack_range : float = 2.0


var dead : bool = false
var on_navmesh : bool = true

var navmesh_speed := 2
var navmesh_acceleration := 10

func _physics_process(delta):
	if dead:
		return
	if player == null:
		return
	if on_navmesh:
		move_on_navmesh(delta)
	else:
		move_outside_navmesh()
	
	move_and_slide()
	
	attempt_to_kill_player()

func move_on_navmesh(delta):
	var direction : Vector3 = Vector3()
	navigation.target_position = player.global_position
	direction = navigation.get_next_path_position() - global_position
	direction = direction.normalized()
	look_at(global_position + direction, Vector3.UP)
	
	velocity = velocity.lerp(direction * navmesh_speed, navmesh_acceleration * delta)
	
func move_outside_navmesh() -> void:
	var direction := player.global_position - global_position
	direction.y = 0.0
	direction = direction.normalized()
	
	look_at(global_position + direction, Vector3.UP)
	
	velocity = direction * move_speed

func attempt_to_kill_player():
	var distance_to_player = global_position.distance_to(player.global_position)
	if distance_to_player > attack_range:
		return
	
	if enemy_shoot_ray.is_colliding() and enemy_shoot_ray.get_collider().has_method("player_kill"):
		player.player_kill()
	
	# Ensure there's no objects in the way
	# var eye_line = Vector3.UP * 1.5
	# var ray_query = PhysicsRayQueryParameters3D.create(global_position + eye_line, player.global_position + eye_line, 1) # 1 relates to the environment layer of the collision mask
	# var result = get_world_3d().direct_space_state.intersect_ray(ray_query)
	# if result.is_empty():
		# player.player_kill()

func kill() -> void :
	dead = true
	$Death_sound.play()
	animated_sprite_3d.play("death")
	$CollisionShape3D.disabled = true
