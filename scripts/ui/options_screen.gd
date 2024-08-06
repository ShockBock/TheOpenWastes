extends Control

## Key mapping code and assocaited node hierarchy based on
## Easy Input Settings Menu | Let's Godot
## by DashNothing, 2023. https://www.youtube.com/watch?v=ZDPM45cHHlI

@onready var input_button_scene = preload("res://Scenes/ui/input_button.tscn")
@export var action_list: VBoxContainer
@export var mouse_inversion_button: MarginContainer
@export var mouse_sensitivity: Button

var is_remapping: bool = false
var action_to_remap = null
var remapping_button = null

## More presentable text for key mapping menu. Gets rid of underscores etc.
var input_actions_dictionary: Dictionary = {
	"forward": "Forward",
	"backward": "Backward",
	"left": "Left",
	"right": "Right",
	"jump": "Jump",
	"sprint": "Sprint",
	"shoot": "Shoot",
	"change_weapon": "Change weapon",
	"exit": "Exit to menu",
}

func _ready():
	clear_action_list()
	populate_action_list_default()


## Clears out any pre-existing key-mapping nodes,
## consisting of input_button.tscn
func clear_action_list() -> void:
	InputMap.load_from_project_settings()
	
	# Empty action list, except for items not in Project Settings => Input Map
	for item in action_list.get_children():
		if (
			item == mouse_inversion_button or 
			item == mouse_sensitivity
			):
			pass
		else:
			item.queue_free()

## Creates new instances of input_button.tscn, based on the number of items in 
## input_actions_dictionary. Then gets input map from project settings and
## assigns appropriate key name to each action's label. 
func populate_action_list_default() -> void:
	display_mouse_sensitivity_current()
	
	for action in input_actions_dictionary:
		var button = input_button_scene.instantiate()
		
		var action_label: Label = button.find_child("LabelAction")
		action_label.text = input_actions_dictionary[action]
		
		var input_label: Label = button.find_child("LabelInput")
		var events = InputMap.action_get_events(action)
		if events.size() > 0:
			input_label.text = events[0].as_text().trim_suffix(" (Physical)")
		else:
			input_label.text = ""
		
		action_list.add_child(button)
		button.pressed.connect(on_input_button_pressed.bind(button, action))


func display_mouse_sensitivity_current() -> void:
	var mouse_sensitivity_slider: HSlider = \
			mouse_sensitivity.find_child("HSliderMouseSensitivity")
	mouse_sensitivity_slider.value = Global.current_mouse_sensitivity


func set_mouse_sensitivity_default() -> void:
	var mouse_sensitivity_slider: HSlider = \
			mouse_sensitivity.find_child("HSliderMouseSensitivity")
	mouse_sensitivity_slider.value = Global.default_mouse_sensitivity

## Called whenever any keymapping button is pressed,
## allowing user to map new key to selected action. 
func on_input_button_pressed(button, action):
	if is_remapping == false:
		is_remapping = true
		action_to_remap = action
		remapping_button = button
		button.find_child("LabelInput").text = "Press new key…"


func _input(event):
	if is_remapping == true:
		if (
			event is InputEventKey or
			(event is InputEventMouseButton and event.pressed)
			):
			
			# Turn double click into single click
			if event is InputEventMouseButton and event.double_click:
				event.double_click = false
			
			InputMap.action_erase_events(action_to_remap)
			InputMap.action_add_event(action_to_remap, event)
			update_action_list(remapping_button, event)
			
			is_remapping = false
			action_to_remap = null
			remapping_button = null
			
			# Prevents input from being captured by nodes further up the hierarchy
			accept_event()


func update_action_list(button, event) -> void:
	button.find_child("LabelInput").text = event.as_text().trim_suffix(" (Physical)")


func _on_reset_button_pressed() -> void:
	clear_action_list()
	set_mouse_sensitivity_default()
	populate_action_list_default()


func _on_main_menu_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/ui/start_screen.tscn")


func _on_invert_mouse_button_toggled(toggled_on) -> void:
	if toggled_on:
		Global.mouse_inverted = true
	else:
		Global.mouse_inverted = false


func _on_h_slider_mouse_sensitivity_value_changed(value):
	Global.current_mouse_sensitivity = value
