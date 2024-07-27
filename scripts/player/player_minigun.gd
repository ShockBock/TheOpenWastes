@icon("res://images/Icons/pistol_icon.png")

extends Node3D

@export_group("Minigun assets")
@export var minigun_skeleton: Skeleton3D
@export var minigun_spinup_audio: AudioStreamPlayer
@export var minigun_burst_audio: AudioStreamPlayer
@export var minigun_spindown_audio: AudioStreamPlayer

@export_group("Minigun characteristics")
@export_range(0.0, 10.0) var barrel_rotation_rate: float = 1.0
@export_range(0.0, 0.9) var barrel_spindown_factor: float = 0.5

@onready var barrel_assembly_bone = minigun_skeleton.find_bone("barrel_assembly")

var barrel_spindown_counter: float = 1.0

func _physics_process(delta) -> void:
	var barrel_assembly_rotation: = \
		minigun_skeleton.get_bone_pose_rotation(barrel_assembly_bone)
	
	if Input.is_action_just_pressed("shoot"):
		pass
		
	if Input.is_action_pressed("shoot"):
		minigun_barrel_spin(barrel_assembly_rotation, delta)

	
	if Input.is_action_just_released("shoot"):
		minigun_spindown(barrel_assembly_rotation, delta)
	

func minigun_barrel_spin(barrel_assembly_rotation, delta) -> void:
	if minigun_burst_audio.playing == false:
		minigun_burst_audio.play()
	else:
		pass
	
	barrel_assembly_rotation.y += barrel_rotation_rate * delta
	
	# Needed because quarternary rotation only works between -1 and 1
	if barrel_assembly_rotation.y >= 1:
		barrel_assembly_rotation.y = -1
	
	minigun_skeleton.set_bone_pose_rotation(barrel_assembly_bone, barrel_assembly_rotation)

func minigun_spindown(barrel_assembly_rotation, delta) -> void:
	minigun_burst_audio.playing = false
	minigun_spindown_audio.play()
	
	barrel_assembly_rotation.y += barrel_rotation_rate * barrel_spindown_factor * delta
		
	# Needed because quarternary rotation only works between -1 and 1
	if barrel_assembly_rotation.y >= 1:
		barrel_assembly_rotation.y = -1
	
	minigun_skeleton.set_bone_pose_rotation(barrel_assembly_bone, barrel_assembly_rotation)

	
	
