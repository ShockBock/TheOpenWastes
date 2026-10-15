@icon("res://common/icons/state_machine_icon.png")
class_name State
extends Node

## Base class for NPC states, managed by an NPCStateMachine.
##
## Adapted from Advanced state machine techniques in Godot 4
## by The Shaggy Dev, 2023
## www.youtube.com/watch?v=bNdFXooM1MQ

@export var animation_name: String

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
## Set by the state machine
var npc: NPC


func enter() -> void:
	npc.animations.play(animation_name)


func exit() -> void:
	pass


func process_input(_event: InputEvent) -> State:
	return null


func process_frame(_delta: float) -> State:
	return null


func process_physics(_delta: float) -> State:
	return null
