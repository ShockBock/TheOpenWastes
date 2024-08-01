@icon("res://images/Icons/state_machine_icon.png")

extends Node

## Adapted from Advanced state machine techniques in Godot 4
## by The Shaggy Dev, 2023
## www.youtube.com/watch?v=bNdFXooM1MQ

@export var starting_state: State
@export var hit_state: State

var current_state: State

# Initialize the state machine by giving each child state a reference to the
# parent object it belongs to and enter the default starting_state.
func init(npc: Node3D, animations: AnimatedSprite3D) -> void:
	for child in get_children():
		child.npc = npc
		child.animations = animations

	# Initialize to the default state
	change_state(starting_state)

# Change to the new state by first calling any exit logic on the current state.
func change_state(new_state: State) -> void:
	if current_state:
		current_state.exit()

	current_state = new_state
	current_state.enter()


# Pass through functions for the Player to call,
# handling state changes as needed.
func process_physics(delta: float) -> void:
	var new_state = current_state.process_physics(delta)
	if new_state:
		change_state(new_state)


func process_input(event: InputEvent) -> void:
	var new_state = current_state.process_input(event)
	if new_state:
		change_state(new_state)


func process_frame(delta: float) -> void:
	var new_state = current_state.process_frame(delta)
	if new_state:
		change_state(new_state)


func taken_hit() -> void:
		change_state(hit_state)
	
