extends Node3D

## Particle style based on GODOT VFX - Easy Explosions Effect Tutorial,
## by Gabriel Aguiar Prod, 2023.
## https://www.youtube.com/watch?v=tjSxICUXMmM

@export_group("Child particle nodes")
@export var sparks: GPUParticles3D
@export var flash: GPUParticles3D
@export var fire: GPUParticles3D

@export_group("Muzzle flash characteristics")
@export var spark_generation_probability: float = 0.2

var muzzle_flash_duration_secs: float
var muzzle_flash_scale_factor: float


func _ready() -> void:
	generate_sparks()
	generate_flash()
	generate_fire()


func generate_sparks() -> void:
	if randf_range(0.0, 1.0) < spark_generation_probability:
		sparks.emitting = true
	else:
		pass


func generate_flash() -> void:
	flash.emitting = true


func generate_fire() -> void:
	fire.emitting = true


func _physics_process(delta):
	muzzle_flash_duration_secs -= delta
	if muzzle_flash_duration_secs <= 0:
		queue_free()
	else:
		return
