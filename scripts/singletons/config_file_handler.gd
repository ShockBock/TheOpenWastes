extends Node

## Maintains game settings between closing and opening the game,
## e.g. key-mapping, mouse sensitivity etc.
## Based on Save and Load Settings in Godot 4 with ConfigFile | Let's Godot,
## by DashNothing, 2024.
## https://www.youtube.com/watch?v=tfqJjDw0o7Y

## Reads, writes and saves .ini file.
var config = ConfigFile.new()
const SETTINGS_FILE_PATH = "user://open_wastes_settings.ini"


func _ready():
	if not FileAccess.file_exists(SETTINGS_FILE_PATH):
		config.set_value("keymapping", "forward", "W")
		config.set_value("keymapping", "backward", "S")
		config.set_value("keymapping", "left", "A")
		config.set_value("keymapping", "right", "D")
		config.set_value("keymapping", "jump", "E")
		config.set_value("keymapping", "sprint", "Shift")
		config.set_value("keymapping", "shoot", "mouse_1")
		config.set_value("keymapping", "change_weapon", "mouse_2")
		config.set_value("keymapping", "exit", "Escape")
		config.set_value("mouse", "mouse_sensitivity", 0.03)
		config.set_value("mouse", "invert_mouse", false)
		
		# For location of save file, see https://youtu.be/tfqJjDw0o7Y?t=104
		config.save(SETTINGS_FILE_PATH)
	else:
		config.load(SETTINGS_FILE_PATH)


func save_mouse_settings(key: String, value) -> void:
	config.set_value("mouse", key, value)
	config.save(SETTINGS_FILE_PATH)


func load_mouse_settings() -> Dictionary:
	var mouse_settings: Dictionary = {}
	for key in config.get_section_keys("mouse"):
		mouse_settings[key] = config.get_value("mouse", key)
	return mouse_settings


func save_keymapping(action: StringName, event) -> void:
	var event_str: String
	if event is InputEventKey:
		# ChatGPT tells me OS = operating system
		event_str = OS.get_keycode_string(event.physical_keycode)
	elif event is InputEventMouseButton:
		event_str = "mouse_" + str(event.button_index)
	
	config.set_value("keymapping", action, event_str)
	config.save(SETTINGS_FILE_PATH)


func load_keymapping() -> Dictionary:
	var keymapping: Dictionary = {}
	for key in config.get_section_keys("keymapping"):
		var input_event
		var event_str: String = config.get_value("keymapping", key)
		
		if event_str.contains("mouse_"):
			input_event = InputEventMouseButton.new()
			# Detailed explanation here: https://youtu.be/tfqJjDw0o7Y?t=651
			input_event.button_index = int(event_str.split("_")[1])
		else:
			input_event = InputEventKey.new()
			input_event = OS.find_keycode_from_string(event_str)
		
		keymapping[key] = input_event
	return keymapping
	
