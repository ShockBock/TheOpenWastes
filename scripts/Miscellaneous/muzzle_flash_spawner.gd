@icon("res://images/Icons/pistol_icon.png")

extends Node3D

@onready var muzzle_flash_scene = preload("res://Scenes/Miscellaneous/muzzle_flash.tscn")

## Tells the instantiated muzzle flash scene when to self-terminate
@export_range (0.0, 2.0) var muzzle_flash_duration_secs: float = 1.0
@export_range (0.01, 1.00) var muzzle_flash_scale_factor: float = 1.0


func _on_player_arm_with_pistol_root_weapon_fired():
	var muzzle_flash_instance = muzzle_flash_scene.instantiate()
	muzzle_flash_instance.muzzle_flash_duration_secs = muzzle_flash_duration_secs
	muzzle_flash_instance.muzzle_flash_scale_factor = muzzle_flash_scale_factor
	add_child(muzzle_flash_instance)
