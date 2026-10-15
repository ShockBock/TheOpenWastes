class_name NPC
extends CharacterBody3D

## A non-player character whose behaviour is driven by an NPCStateMachine.

signal died

@export var stats: NPCStats
@export var animations: AnimatedSprite3D
@export var state_machine: NPCStateMachine

var health: float
var last_damage_taken: float = 0.0
var is_dead: bool = false
## What the NPC hunts: currently always the player
var target: Node3D


func _ready() -> void:
	health = stats.max_health
	target = get_tree().get_first_node_in_group("player") as Node3D
	state_machine.init(self)


func take_damage(amount: float) -> void:
	if is_dead:
		return
	last_damage_taken = amount
	state_machine.taken_hit()


func _unhandled_input(event: InputEvent) -> void:
	state_machine.process_input(event)


func _physics_process(delta: float) -> void:
	state_machine.process_physics(delta)


func _process(delta: float) -> void:
	state_machine.process_frame(delta)
