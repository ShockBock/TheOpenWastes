@icon("res://common/icons/pistol_icon.png")
extends Node3D

## Fires the pistol: plays the shot sound and recoil, and emits weapon_fired
## for the projectile spawner and muzzle flash.

signal weapon_fired

@export_group("Pistol assets")
@export var pistol_shot_audio: AudioStreamPlayer
@export var pistol_shot_animation: AnimationPlayer


func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("shoot") and not pistol_shot_animation.is_playing():
		pistol_shot_audio.play()
		pistol_shot_animation.play("Recoil")
		weapon_fired.emit()
