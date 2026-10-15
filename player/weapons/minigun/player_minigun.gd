@icon("res://common/icons/pistol_icon.png")
extends Node3D

## Spins the minigun's barrels, plays its sound effects and emits
## weapon_fired at the stats' fire rate while shoot is held.

signal weapon_fired

@export var stats: MinigunStats

@export_group("Minigun assets")
@export var minigun_skeleton: Skeleton3D
@export var minigun_burst_audio: AudioStreamPlayer
@export var minigun_burst_audio_loop_start_secs: float = 1.0
@export var minigun_burst_audio_loop_end_secs: float = 3.0
@export var minigun_spindown_audio: AudioStreamPlayer

var barrel_spindown_maximum: float = 1.0
var barrel_spindown_current: float
var current_rotation: float = 0.0
var inter_shot_interval_current: float = 1.0

@onready var barrel_assembly_bone: int = minigun_skeleton.find_bone("barrel_assembly")


func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("shoot"):
		minigun_spindown_audio.playing = false
		minigun_barrel_spin(delta)
		minigun_projectiles(delta)

	if Input.is_action_just_released("shoot"):
		barrel_spindown_current = barrel_spindown_maximum
		minigun_burst_audio.playing = false
		minigun_spindown(delta)

	if minigun_spindown_audio.playing:
		minigun_spindown(delta)


func minigun_projectiles(delta: float) -> void:
	inter_shot_interval_current -= delta * stats.fire_rate_factor
	if inter_shot_interval_current < 0:
		weapon_fired.emit()
		inter_shot_interval_current = 1.0


## Loops the burst sound and spins the Skeleton3D bone that turns the barrels.
func minigun_barrel_spin(delta: float) -> void:
	if not minigun_burst_audio.playing:
		minigun_burst_audio.play()
	if minigun_burst_audio.get_playback_position() > minigun_burst_audio_loop_end_secs:
		minigun_burst_audio.playing = false
		minigun_burst_audio.play(minigun_burst_audio_loop_start_secs)

	current_rotation += stats.barrel_rotation_rate * delta
	set_barrel_rotation()


func minigun_spindown(delta: float) -> void:
	if barrel_spindown_current <= 0:
		return

	if not minigun_spindown_audio.playing:
		minigun_spindown_audio.play()

	barrel_spindown_current -= delta
	current_rotation += stats.barrel_rotation_rate * barrel_spindown_current * delta
	set_barrel_rotation()


## Explanation of the quaternion rotation:
## https://www.youtube.com/watch?v=Ri2xIhcii8I
func set_barrel_rotation() -> void:
	minigun_skeleton.set_bone_pose_rotation(
		barrel_assembly_bone, Quaternion(Vector3.UP, current_rotation)
	)
