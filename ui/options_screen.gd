extends Control

## Options menu: key remapping and mouse settings, saved through the Settings
## autoload.
##
## Key mapping code and associated node hierarchy based on
## "Easy Input Settings Menu | Let's Godot",
## https://www.youtube.com/watch?v=ZDPM45cHHlI, and
## "Save and Load Settings in Godot 4 with ConfigFile | Let's Godot",
## https://www.youtube.com/watch?v=tfqJjDw0o7Y, by DashNothing

## Remappable actions, with the names shown in the menu
const ACTION_LABELS: Dictionary[String, String] = {
	"forward": "Forward",
	"backward": "Backward",
	"left": "Left",
	"right": "Right",
	"jump": "Jump",
	"sprint": "Sprint",
	"shoot": "Shoot",
	"change_weapon": "Change weapon",
	"free_mouse": "Free mouse",
	"exit": "Exit to menu",
}

@export var input_button_scene: PackedScene
@export_file("*.tscn") var main_menu_scene: String
@export var action_list: VBoxContainer
@export var mouse_sensitivity_slider: HSlider
@export var invert_mouse_button: Button

var action_to_remap: String = ""
var remapping_button: Button


func _ready() -> void:
	load_mouse_settings()
	populate_action_list()


func load_mouse_settings() -> void:
	mouse_sensitivity_slider.value = Settings.get_mouse_sensitivity()
	invert_mouse_button.set_pressed_no_signal(Settings.get_invert_mouse())


## Replaces the placeholder buttons with one button per remappable action,
## labelled with its current binding.
func populate_action_list() -> void:
	for item: Node in action_list.get_children():
		if item.name.contains("Button"):
			item.queue_free()

	for action: String in ACTION_LABELS:
		var button: Button = input_button_scene.instantiate()
		button.find_child("LabelAction").text = ACTION_LABELS[action]
		var events: Array[InputEvent] = InputMap.action_get_events(action)
		button.find_child("LabelInput").text = event_label(events[0]) if events.size() > 0 else ""
		action_list.add_child(button)
		button.pressed.connect(_on_input_button_pressed.bind(button, action))


func event_label(event: InputEvent) -> String:
	return event.as_text().trim_suffix(" (Physical)").trim_suffix(" - Physical")


## Waits for the next key or mouse button to bind to action.
func _on_input_button_pressed(button: Button, action: String) -> void:
	if action_to_remap.is_empty():
		action_to_remap = action
		remapping_button = button
		button.find_child("LabelInput").text = "Press new key…"


func _input(event: InputEvent) -> void:
	if action_to_remap.is_empty():
		return
	if not (event is InputEventKey or (event is InputEventMouseButton and event.pressed)):
		return

	# Turn a double click into a single click
	if event is InputEventMouseButton:
		event.double_click = false

	Settings.remap_action(action_to_remap, event)
	remapping_button.find_child("LabelInput").text = event_label(event)
	action_to_remap = ""
	remapping_button = null

	# Stops the input reaching other nodes
	accept_event()


func _on_reset_button_pressed() -> void:
	Settings.reset_keymapping()
	Settings.reset_mouse()
	load_mouse_settings()
	populate_action_list()


func _on_main_menu_button_pressed() -> void:
	get_tree().change_scene_to_file(main_menu_scene)


func _on_invert_mouse_button_toggled(toggled_on: bool) -> void:
	Settings.set_invert_mouse(toggled_on)


func _on_h_slider_mouse_sensitivity_drag_ended(value_changed: bool) -> void:
	if value_changed:
		Settings.set_mouse_sensitivity(mouse_sensitivity_slider.value)
