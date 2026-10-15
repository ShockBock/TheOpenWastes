class_name Player
extends CharacterBody3D

## Player character controller.
##
## Based heavily on LegionGames'
## Juiced Up First Person Character Controller Tutorial - Godot 3D FPS.
##
## @tutorial: www.youtube.com/watch?v=A3HLeyaBCq4

signal died

@export var walk_speed: float = 5.0
@export var sprint_speed: float = 8.0
@export var jump_velocity: float = 4.5
@export var max_health: float = 100.0

@export_group("Head bob")
@export var bob_frequency: float = 2.0
@export var bob_amplitude: float = 0.08

@export_group("Field of view (FOV)")
@export var base_fov: float = 75.0
@export var fov_change: float = 1.5

@export_group("Plug-in nodes")
@export var head: Node3D
@export var camera: Camera3D
@export var health_counter: Label

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var health: float
var mouse_freed: bool = false
var speed: float = 0.0
var t_bob: float = 0.0
var mouse_inverted: bool
var mouse_sensitivity: float
## The building the player is inside, set by the building; null when outdoors
var current_building: Node3D


func _ready() -> void:
	# Use mouse movement to turn the camera, rather than move a pointer
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	health = max_health
	update_health_counter()

	mouse_sensitivity = Settings.get_mouse_sensitivity()
	mouse_inverted = Settings.get_invert_mouse()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and not mouse_freed:
		head.rotate_y(-event.relative.x * mouse_sensitivity)
		var y_sensitivity: float = -mouse_sensitivity if mouse_inverted else mouse_sensitivity
		camera.rotate_x(-event.relative.y * y_sensitivity)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-40), deg_to_rad(60))

	if event.is_action_pressed("free_mouse"):
		mouse_freed = not mouse_freed
		Input.mouse_mode = (Input.MOUSE_MODE_VISIBLE if mouse_freed else Input.MOUSE_MODE_CAPTURED)


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta
	elif Input.is_action_just_pressed("jump"):
		velocity.y = jump_velocity
	else:
		velocity.y = -0.5

	speed = sprint_speed if Input.is_action_pressed("sprint") else walk_speed

	var input_dir: Vector2 = Input.get_vector("left", "right", "forward", "backward")
	var direction: Vector3 = (
		(head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	)

	if is_on_floor():
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			# Inertial die-off when the player stops moving on the ground
			velocity.x = lerp(velocity.x, direction.x * speed, delta * 7.0)
			velocity.z = lerp(velocity.z, direction.z * speed, delta * 7.0)
	else:
		# Keeps most of the jump's direction until the player lands
		velocity.x = lerp(velocity.x, direction.x * speed, delta * 2.0)
		velocity.z = lerp(velocity.z, direction.z * speed, delta * 2.0)

	t_bob += delta * velocity.length() * float(is_on_floor())
	camera.transform.origin = headbob(t_bob)

	var velocity_clamped: float = clamp(velocity.length(), 0.5, sprint_speed * 2)
	var target_fov: float = base_fov + fov_change * velocity_clamped
	camera.fov = lerp(camera.fov, target_fov, delta * 8.0)

	move_and_slide()


func headbob(time: float) -> Vector3:
	return Vector3(
		cos(time * bob_frequency / 2) * bob_amplitude,
		sin(time * bob_frequency) * bob_amplitude,
		0,
	)


func take_damage(amount: float) -> void:
	if health <= 0:
		return
	health -= amount
	update_health_counter()
	if health <= 0:
		died.emit()


func update_health_counter() -> void:
	health_counter.text = str(ceili(max(health, 0.0)))
