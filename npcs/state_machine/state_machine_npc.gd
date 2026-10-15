@icon("res://common/icons/state_machine_icon.png")
class_name NPCStateMachine
extends Node

## Runs an NPC's current State and switches between states.
##
## Adapted from Advanced state machine techniques in Godot 4
## by The Shaggy Dev, 2023
## www.youtube.com/watch?v=bNdFXooM1MQ

@export var starting_state: State
@export var hit_state: State

var current_state: State


## Gives each child state a reference to the NPC it controls, then enters the
## starting state.
func init(npc: NPC) -> void:
	for child: Node in get_children():
		if child is State:
			child.npc = npc

	change_state(starting_state)


## Changes to a new state, calling any exit logic on the current state first.
func change_state(new_state: State) -> void:
	if current_state:
		current_state.exit()

	current_state = new_state
	current_state.enter()


# Pass-through functions for the NPC to call, changing state as needed.
func process_physics(delta: float) -> void:
	var new_state: State = current_state.process_physics(delta)
	if new_state:
		change_state(new_state)


func process_input(event: InputEvent) -> void:
	var new_state: State = current_state.process_input(event)
	if new_state:
		change_state(new_state)


func process_frame(delta: float) -> void:
	var new_state: State = current_state.process_frame(delta)
	if new_state:
		change_state(new_state)


func taken_hit() -> void:
	change_state(hit_state)
