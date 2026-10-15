extends Node3D

## Handles visibilty, scaling and rotation of muzzle flash assets,
## which are positioned in front of the weapon, parented to a Marker3D.
## Can be used for all types of firearm.

@export_group("Muzzle flash assets")
@export var weapon_data: Node
@export var flash: MeshInstance3D
@export var flare: MeshInstance3D
@export var sparks: GPUParticles3D

@export_group("Muzzle flash characteristics")
## Min size of displayed muzzle flash assets 
@export var scaling_factor_rand_min: float = 0.0
## Max size of displayed muzzle flash assets 
@export var scaling_factor_rand_max: float = 1.0
## Sets rate at which muzzle flash assets shrink
@export var muzzle_flash_decay_factor: float = 0.6

@onready var flash_scaling = flash.scale * weapon_data.main_flash_scale_factor
@onready var flare_scaling = flare.scale * weapon_data.main_flash_scale_factor

var current_flash_duration: float

func _ready() -> void:
	flash.visible = false
	flare.visible = false

## Signal and function name must match,
## as the muzzle flash script is shared with other weapons.
func _on_weapon_fired():
	current_flash_duration = weapon_data.muzzle_flash_duration_secs
	generate_sparks()
	display_flash()
	display_flare()


## Determines whether shot generates sparks and if so, triggers child GPUParticles3D.
## Assets and implementation from GODOT VFX - Easy Explosions Effect Tutorial.
## Gabriel Aguiar Prod. https://www.youtube.com/watch?v=tjSxICUXMmM
func generate_sparks() -> void:
	if randf_range(0.0, 1.0) < weapon_data.spark_generation_probability:
		sparks.emitting = true
	else:
		pass


## Makes child flash MeshInstance3D visible and adds random rotation and scaling.
func display_flash() -> void:
	flash.visible = true
	flash.rotation.z = randf_range(-180, 180)
	flash.scale = flash_scaling
	flash.scale *= randf_range(scaling_factor_rand_min, scaling_factor_rand_max)


## Makes child flare MeshInstance3D visible and adds scaling.
func display_flare() -> void:
	flare.visible = true
	flare.scale = flare_scaling
	flare.scale *= randf_range(scaling_factor_rand_min, scaling_factor_rand_max)


func _physics_process(delta):
	current_flash_duration -= delta
	if current_flash_duration <= 0:
		flash.visible = false
		flare.visible = false
	else:
		flash.scale *= muzzle_flash_decay_factor
		flare.scale *= muzzle_flash_decay_factor
