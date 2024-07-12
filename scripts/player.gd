# Many thanks to LegionGames'
# Juiced Up First Person Character Controller Tutorial - Godot 3D FPS
# www.youtube.com/watch?v=A3HLeyaBCq4

extends CharacterBody3D

signal weapon_fired

@export_group("Weapons")
## Max damage per projectile. Ideally should attenuate with range
@export_range(0, 20) var pistol_projectile_max_damage : float = 20
## Time (secs) until projectile deletes itself, if not having collided with anything
@export_range(0, 5) var pistol_projectile_life_secs : float = 2
## Speed of each projectile
@export var pistol_projectile_speed : float = 1.0
@export_subgroup("Projectile offsets")
## player-perspective x-offset of projectile spawn point
@export_range(-1, 1) var pistol_projectile_spawn_x_offset : float = 0.0
## player-perspective y-offset of projectile spawn point
@export_range(-1, 1) var pistol_projectile_spawn_y_offset : float = 1.0
## Offset of projectile spawn point, in direction of fire
@export_range(-1, 1) var pistol_projectile_spawn_distance_offset : float = 0.0

var speed
const WALK_SPEED = 5.0
const SPRINT_SPEED = 8.0
const JUMP_VELOCITY = 4.5
const SENSITIVITY = 0.015

# bob (walking motion) variables
const BOB_FREQ = 2.0
const BOB_AMP = 0.08
var t_bob = 0.0

# fov variables (for altering camera field depending on player speed).
const BASE_FOV = 75.0 # Gives player option to change intensity in settings.
const FOV_CHANGE = 1.5 # Reactivity to speed changes.

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = 9.8
var health : int = 100

@onready var head = $Head
@onready var camera = $Head/Camera3D
@onready var health_counter = $CanvasLayer/HUD/HealthCounter
@onready var pistol_shot_audio : AudioStreamPlayer = $Audio/PistolShot
@onready var pistol_shot_animation : AnimationPlayer = \
		$Head/Camera3D/PlayerArmWithPistol/PlayerArmAnimationPlayer


func _ready() :
	# Use mouse as movement for camera, rather than pointer
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	health_counter.text = str(health)


func _unhandled_input(event) :
	if event is InputEventMouseMotion :
		head.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-40), deg_to_rad(60))


func _physics_process(delta) -> void :
	# Add gravity.
	if not is_on_floor() :
		velocity.y -= gravity * delta
	else :
		# Handle Jump.
		if Input.is_action_just_pressed("jump") :
			velocity.y = JUMP_VELOCITY
		else :
			velocity.y = -0.5
		
	# Handle Sprint.
	if Input.is_action_pressed("sprint") :
		speed = SPRINT_SPEED
	else :
		speed = WALK_SPEED
	
	if Input.is_action_just_pressed("shoot") and not pistol_shot_animation.is_playing() :
		pistol_shot_audio.play()
		pistol_shot_animation.play("Recoil")
		emit_signal("weapon_fired")
		
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	var direction : Vector3 = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		
	if is_on_floor() :
		if direction :
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else :
			# Adds inertial die-off when player stops moving (on ground).
			velocity.x = lerp(velocity.x, direction.x * speed, delta * 7.0)
			velocity.z = lerp(velocity.z, direction.x * speed, delta * 7.0)
	else :
		# Maintains direction once jumped until ground reached.
		velocity.x = lerp(velocity.x, direction.x * speed, delta * 2.0)
		velocity.z = lerp(velocity.z, direction.x * speed, delta * 2.0)
		
	# Head bob
	t_bob += delta * velocity.length() * float(is_on_floor())
	camera.transform.origin = _headbob(t_bob)
	
	# FOV
	var velocity_clamped = clamp(velocity.length(), 0.5, SPRINT_SPEED * 2)
	var target_fov = BASE_FOV + FOV_CHANGE * velocity_clamped
	camera.fov = lerp(camera.fov, target_fov, delta * 8.0)
	
	move_and_slide()


func _headbob(time) -> Vector3 :
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ / 2) * BOB_AMP
	return pos


func health_tracker(max_damage) -> void :
	health -= max_damage
	health_counter.text = str(health)
	if health <= 0 :
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		var player_died = get_node("/root/OpenWastes/MAIN_SEQUENCE")
		player_died.end_game()
