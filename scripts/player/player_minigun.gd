@icon("res://images/Icons/pistol_icon.png")

extends Node3D

## Handles player minigun barrel rotation and sound effects.

signal weapon_fired

@export var minigun_data: Node

@export_group("Minigun assets")
@export var minigun_skeleton: Skeleton3D
@export var minigun_burst_audio: AudioStreamPlayer
@export var minigun_burst_audio_loop_start_secs: float = 1.0
@export var minigun_burst_audio_loop_end_secs: float = 3.0
@export var minigun_spindown_audio: AudioStreamPlayer

@onready var barrel_assembly_bone = minigun_skeleton.find_bone("barrel_assembly")

var barrel_spindown_maximum: float = 1.0
var barrel_spindown_current: float
var current_rotation: float = 0.0
var inter_shot_interval_current: float = 1.0

func _physics_process(delta) -> void:
	var barrel_bone_rotation: = \
		minigun_skeleton.get_bone_pose_rotation(barrel_assembly_bone)
	
	if Input.is_action_just_pressed("shoot"):
		pass
	
	if Input.is_action_pressed("shoot"):
		minigun_spindown_audio.playing = false
		minigun_barrel_spin(barrel_bone_rotation, delta)
		minigun_projectiles(delta)
	
	if Input.is_action_just_released("shoot"):
		barrel_spindown_current = barrel_spindown_maximum
		minigun_burst_audio.playing = false
		minigun_spindown(barrel_bone_rotation, delta)
	
	if minigun_spindown_audio.playing == true:
		minigun_spindown(barrel_bone_rotation, delta)


func minigun_projectiles(delta) -> void:
	inter_shot_interval_current -= delta * minigun_data.fire_rate_factor
	if inter_shot_interval_current >= 0:
		pass
	else:
		emit_signal("weapon_fired")
		inter_shot_interval_current = 1.0


## Handles MinigunBurst AudioStreamPlayer
## and spins Skeleton3D bone which turn the barrels
func minigun_barrel_spin(barrel_bone_rotation, delta) -> void:
	if minigun_burst_audio.playing == false:
		minigun_burst_audio.play()
	if minigun_burst_audio.get_playback_position() > minigun_burst_audio_loop_end_secs:
		minigun_burst_audio.playing = false
		minigun_burst_audio.play(minigun_burst_audio_loop_start_secs)
	else:
		pass
	
	current_rotation += minigun_data.barrel_rotation_rate * delta
	
	# Weird quaternion stuff! I don't understand why or how it works either.
	# Detailed explanation here: https://www.youtube.com/watch?v=Ri2xIhcii8I
	var rotation_quat = Quaternion(Vector3.UP, current_rotation)
	barrel_bone_rotation = rotation_quat
	
	minigun_skeleton.set_bone_pose_rotation(barrel_assembly_bone, barrel_bone_rotation)


func minigun_spindown(barrel_bone_rotation, delta) -> void:
	if barrel_spindown_current <= 0:
		return
	
	if minigun_spindown_audio.playing == false:
		minigun_spindown_audio.play()
	
	barrel_spindown_current -= delta
	current_rotation += minigun_data.barrel_rotation_rate * barrel_spindown_current * delta
	
	var rotation_quat = Quaternion(Vector3.UP, current_rotation)
	barrel_bone_rotation = rotation_quat
	
	minigun_skeleton.set_bone_pose_rotation(barrel_assembly_bone, barrel_bone_rotation)
