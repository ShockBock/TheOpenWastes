@icon("res://common/icons/pistol_icon.png")
extends Node3D

## Holds the player's current weapon and cycles through weapon_scenes when
## change_weapon is pressed.

@export var weapon_scenes: Array[PackedScene] = []

var weapon_selection: int = 0


func _ready() -> void:
	equip_selected_weapon()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("change_weapon"):
		weapon_selection = (weapon_selection + 1) % weapon_scenes.size()
		equip_selected_weapon()


func equip_selected_weapon() -> void:
	for child: Node in get_children():
		child.queue_free()
	add_child(weapon_scenes[weapon_selection].instantiate())
