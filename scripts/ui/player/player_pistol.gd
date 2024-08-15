@icon("res://images/Icons/pistol_icon.png")

extends Node3D

signal weapon_fired

@export_group("Pistol assets")
@export var pistol_shot_audio: AudioStreamPlayer
@export var pistol_shot_animation: AnimationPlayer
@export var muzzle_flash: Node3D

func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("shoot") and not pistol_shot_animation.is_playing():
		pistol_shot_audio.play()
		pistol_shot_animation.play("Recoil")
		emit_signal("weapon_fired")
