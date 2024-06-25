class_name Shotgun_monk
extends CharacterBody3D

@onready
var animations : AnimatedSprite3D = %Shotgun_monk_animations

@onready
var state_machine : Node = %State_machine

@export_range(0, 3) var move_speed : float = 1

func _ready() -> void:
	state_machine.init(self, animations)

func _unhandled_input(event: InputEvent) -> void:
	state_machine.process_input(event)

func _physics_process(delta: float) -> void:
	state_machine.process_physics(delta)

func _process(delta: float) -> void:
	state_machine.process_frame(delta)
