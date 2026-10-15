extends Node3D

## Shows, scales and rotates the muzzle flash assets, which sit in front of
## the weapon under a Marker3D. Shared by every firearm.

@export_group("Muzzle flash assets")
@export var stats: WeaponStats
@export var flash: MeshInstance3D
@export var flare: MeshInstance3D
@export var sparks: GPUParticles3D

@export_group("Muzzle flash characteristics")
## Min size of displayed muzzle flash assets
@export var scaling_factor_rand_min: float = 0.0
## Max size of displayed muzzle flash assets
@export var scaling_factor_rand_max: float = 1.0
## Rate at which muzzle flash assets shrink
@export var muzzle_flash_decay_factor: float = 0.6

var current_flash_duration: float

@onready var flash_scaling: Vector3 = flash.scale * stats.main_flash_scale_factor
@onready var flare_scaling: Vector3 = flare.scale * stats.main_flash_scale_factor


func _ready() -> void:
	flash.visible = false
	flare.visible = false


## Connected to the weapon's weapon_fired signal.
func _on_weapon_fired() -> void:
	current_flash_duration = stats.muzzle_flash_duration_secs
	generate_sparks()
	display_flash()
	display_flare()


## Randomly decides whether the shot throws sparks.
## Assets and implementation from GODOT VFX - Easy Explosions Effect Tutorial.
## Gabriel Aguiar Prod. https://www.youtube.com/watch?v=tjSxICUXMmM
func generate_sparks() -> void:
	if randf() < stats.spark_generation_probability:
		sparks.emitting = true


## Shows the flash with a random rotation and scale.
func display_flash() -> void:
	flash.visible = true
	flash.rotation.z = randf_range(-180, 180)
	flash.scale = flash_scaling * randf_range(scaling_factor_rand_min, scaling_factor_rand_max)


## Shows the flare with a random scale.
func display_flare() -> void:
	flare.visible = true
	flare.scale = flare_scaling * randf_range(scaling_factor_rand_min, scaling_factor_rand_max)


func _physics_process(delta: float) -> void:
	current_flash_duration -= delta
	if current_flash_duration <= 0:
		flash.visible = false
		flare.visible = false
	else:
		flash.scale *= muzzle_flash_decay_factor
		flare.scale *= muzzle_flash_decay_factor
