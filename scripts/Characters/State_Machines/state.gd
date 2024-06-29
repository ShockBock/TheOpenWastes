class_name State
## Referred to by state machine nodes

extends Node

@export
var animation_name: String

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

var animations: AnimatedSprite3D
var move_component
var parent: CharacterBody3D

func enter() -> void:
	animations.play(animation_name)

func exit() -> void:
	pass

func process_input(_event: InputEvent) -> State:
	return null

func process_frame(_delta: float) -> State:
	return null

func process_physics(_delta: float) -> State:
	return null

func get_movement_input() -> float:
	return move_component.get_movement_direction()

func get_jump() -> bool:
	return move_component.wants_jump()

# Adapted from Advanced state machine techniques in Godot 4
# by The Shaggy Dev, 2023
# www.youtube.com/watch?v=bNdFXooM1MQ
