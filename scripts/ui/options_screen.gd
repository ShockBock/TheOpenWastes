extends Control

## Key mapping code and associated node hierarchy based on
## "Easy Input Settings Menu | Let's Godot",
## https://www.youtube.com/watch?v=ZDPM45cHHlI, and
## "Save and Load Settings in Godot 4 with ConfigFile | Let's Godot", 
## https://www.youtube.com/watch?v=tfqJjDw0o7Y, by DashNothing

@onready var input_button_scene = preload("res://Scenes/ui/input_button.tscn")

@export var action_list: VBoxContainer
@export var mouse_sensitivity_slider: HSlider
@export var invert_mouse_button: Button

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
	import_mouse_settings()
	import_keymapping_settings()
	clear_action_list()
	populate_action_list()


## Loads mouse settings from the singleton config_file_handler.gd
func import_mouse_settings() -> void:
	var mouse_settings: Dictionary = ConfigFileHandler.load_mouse_settings()
	
	mouse_sensitivity_slider.value = mouse_settings.mouse_sensitivity
	invert_mouse_button.button_pressed = mouse_settings.invert_mouse


## Loads keymapping from the singleton config_file_handler.gd
func import_keymapping_settings() -> void:
	var keymapping: Dictionary = ConfigFileHandler.load_keymapping()
	for action in keymapping.keys():
		InputMap.action_erase_events(action)
		var event = keymapping[action]
		# This if/else section courtesy of ChatGPT,
		# as the method in the DashNothing tutorial caused a mixed variable type error.
		if typeof(event) == TYPE_INT:
			# If the event is an integer, convert it to an InputEventKey
			var input_event := InputEventKey.new()
			input_event.keycode = event
			InputMap.action_add_event(action, input_event)
		elif event is InputEvent:
			# If it's already an InputEvent, just add it
			InputMap.action_add_event(action, event)
		else:
			# Handle other types if necessary
			print("Unsupported event type for action: %s" % action)



## Clears out any pre-existing key-mapping nodes,
## consisting of input_button.tscn
func clear_action_list() -> void:
	for item in action_list.get_children():
		if not item.name.contains("Button"):
			pass
		else:
			item.queue_free()


## Creates new instances of input_button.tscn, based on the number of items in 
## input_actions_dictionary. Then gets input map from project settings and
## assigns appropriate key name to each action's label. 
func populate_action_list() -> void:
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


func set_mouse_defaults() -> void:
	mouse_sensitivity_slider.value = Global.default_mouse_sensitivity
	ConfigFileHandler.save_mouse_settings("mouse_sensitivity", mouse_sensitivity_slider.value)
	invert_mouse_button.button_pressed = false
	ConfigFileHandler.save_mouse_settings("invert_mouse", false)
	


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
			ConfigFileHandler.save_keymapping(action_to_remap, event)
			update_action_list(remapping_button, event)
			
			is_remapping = false
			action_to_remap = null
			remapping_button = null
			
			# Prevents input from being captured by nodes further up the hierarchy
			accept_event()


func update_action_list(button, event) -> void:
	button.find_child("LabelInput").text = event.as_text().trim_suffix(" (Physical)")


func _on_reset_button_pressed() -> void:
	InputMap.load_from_project_settings()
	for action in input_actions_dictionary:
		var events = InputMap.action_get_events(action)
		if events.size() > 0:
			ConfigFileHandler.save_keymapping(action, events[0])
	clear_action_list()
	populate_action_list()
	set_mouse_defaults()


func _on_main_menu_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/ui/start_screen.tscn")


func _on_invert_mouse_button_toggled(toggled_on) -> void:
	ConfigFileHandler.save_mouse_settings("invert_mouse", toggled_on)


func _on_h_slider_mouse_sensitivity_drag_ended(value_changed):
	if value_changed:
		ConfigFileHandler.save_mouse_settings("mouse_sensitivity", mouse_sensitivity_slider.value)
