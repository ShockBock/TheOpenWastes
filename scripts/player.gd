extends CharacterBody3D

## Based heavily on LegionGames'
## Juiced Up First Person Character Controller Tutorial - Godot 3D FPS.
## www.youtube.com/watch?v=A3HLeyaBCq4

@export var walk_speed: float = 5.0
@export var sprint_speed: float = 8.0
@export var jump_velocity: float = 4.5

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

@onready var mouse_settings: Dictionary = ConfigFileHandler.load_mouse_settings()

var gravity: float = 9.8
var health: int = 100
var mouse_freed: bool

var speed: float = 0.0
var t_bob: float = 0.0

var mouse_inverted: bool
var mouse_sensitivity: float


func _ready() -> void:
	# Use mouse as movement for camera, rather than pointer
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	health_counter.text = str(health)
	mouse_freed = false
	
	mouse_sensitivity = mouse_settings.mouse_sensitivity
	mouse_inverted = mouse_settings.invert_mouse


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and mouse_freed == false:
		head.rotate_y(-event.relative.x * mouse_sensitivity)
		var y_sensitivity
		if mouse_inverted:
			y_sensitivity = -mouse_sensitivity
		else:
			y_sensitivity = mouse_sensitivity
		camera.rotate_x(-event.relative.y * y_sensitivity)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-40), deg_to_rad(60))
	
	if Input.is_action_just_pressed("free_mouse"):
		if mouse_freed == false:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			mouse_freed = true
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			mouse_freed = false

func _physics_process(delta: float) -> void:
	# Add gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		# Handle Jump.
		if Input.is_action_just_pressed("jump"):
			velocity.y = jump_velocity
		else:
			velocity.y = -0.5
	
	# Handle Sprint.
	if Input.is_action_pressed("sprint"):
		speed = sprint_speed
	else:
		speed = walk_speed
	
	# Get the input direction and handle the movement/deceleration.
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	var direction: Vector3 = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if is_on_floor():
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			# Adds inertial die-off when player stops moving (on ground).
			velocity.x = lerp(velocity.x, direction.x * speed, delta * 7.0)
			velocity.z = lerp(velocity.z, direction.x * speed, delta * 7.0)
	else:
		# Maintains direction once jumped until ground reached.
		velocity.x = lerp(velocity.x, direction.x * speed, delta * 2.0)
		velocity.z = lerp(velocity.z, direction.x * speed, delta * 2.0)
	
	# Head bob
	t_bob += delta * velocity.length() * float(is_on_floor())
	camera.transform.origin = _headbob(t_bob)
	
	# FOV
	var velocity_clamped = clamp(velocity.length(), 0.5, sprint_speed * 2)
	var target_fov = base_fov + fov_change * velocity_clamped
	camera.fov = lerp(camera.fov, target_fov, delta * 8.0)

	move_and_slide()
	
	if Input.is_action_just_pressed("exit"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		get_tree().change_scene_to_file("res://Scenes/ui/start_screen.tscn")


func _headbob(time: float) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * bob_frequency) * bob_amplitude
	pos.x = cos(time * bob_frequency / 2) * bob_amplitude
	return pos


func track_health(damage: int) -> void:
	health -= damage
	health_counter.text = str(health)
	if health <= 0:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		var player_died = get_node("/root/OpenWastes/MAIN_SEQUENCE")
		player_died.end_game()
