extends Node

## Game settings that persist between sessions: key mapping and mouse.
##
## Default key bindings come from the project's Input Map; the settings file
## only records actions the player has remapped. Missing values fall back to
## the defaults, so older settings files keep working.
##
## Based on Save and Load Settings in Godot 4 with ConfigFile | Let's Godot,
## by DashNothing, 2024. https://www.youtube.com/watch?v=tfqJjDw0o7Y

const SETTINGS_FILE_PATH: String = "user://open_wastes_settings.ini"
const DEFAULT_MOUSE_SENSITIVITY: float = 0.03
const DEFAULT_INVERT_MOUSE: bool = false

var config: ConfigFile = ConfigFile.new()


func _ready() -> void:
	if FileAccess.file_exists(SETTINGS_FILE_PATH):
		config.load(SETTINGS_FILE_PATH)
	apply_keymapping()


func get_mouse_sensitivity() -> float:
	return config.get_value("mouse", "mouse_sensitivity", DEFAULT_MOUSE_SENSITIVITY)


func set_mouse_sensitivity(value: float) -> void:
	config.set_value("mouse", "mouse_sensitivity", value)
	config.save(SETTINGS_FILE_PATH)


func get_invert_mouse() -> bool:
	return config.get_value("mouse", "invert_mouse", DEFAULT_INVERT_MOUSE)


func set_invert_mouse(value: bool) -> void:
	config.set_value("mouse", "invert_mouse", value)
	config.save(SETTINGS_FILE_PATH)


func reset_mouse() -> void:
	if config.has_section("mouse"):
		config.erase_section("mouse")
	config.save(SETTINGS_FILE_PATH)


## Binds action to event, replacing its existing bindings, and saves it.
func remap_action(action: StringName, event: InputEvent) -> void:
	InputMap.action_erase_events(action)
	InputMap.action_add_event(action, event)
	config.set_value("keymapping", action, event_to_string(event))
	config.save(SETTINGS_FILE_PATH)


## Restores every action to the project's default bindings.
func reset_keymapping() -> void:
	InputMap.load_from_project_settings()
	if config.has_section("keymapping"):
		config.erase_section("keymapping")
	config.save(SETTINGS_FILE_PATH)


## Replaces the default bindings of remapped actions with the saved ones.
func apply_keymapping() -> void:
	if not config.has_section("keymapping"):
		return
	for action: String in config.get_section_keys("keymapping"):
		if not InputMap.has_action(action):
			continue
		var event: InputEvent = string_to_event(config.get_value("keymapping", action))
		if event != null:
			InputMap.action_erase_events(action)
			InputMap.action_add_event(action, event)


## Keys are stored by name (e.g. "W", "Shift"), mouse buttons as "mouse_<n>".
func event_to_string(event: InputEvent) -> String:
	if event is InputEventMouseButton:
		return "mouse_" + str(event.button_index)
	if event is InputEventKey:
		var keycode: Key = event.physical_keycode if event.physical_keycode else event.keycode
		return OS.get_keycode_string(keycode)
	return ""


func string_to_event(text: String) -> InputEvent:
	if text.begins_with("mouse_"):
		var mouse_event: InputEventMouseButton = InputEventMouseButton.new()
		mouse_event.button_index = int(text.trim_prefix("mouse_")) as MouseButton
		return mouse_event
	var keycode: Key = OS.find_keycode_from_string(text)
	if keycode == KEY_NONE:
		return null
	var key_event: InputEventKey = InputEventKey.new()
	key_event.physical_keycode = keycode
	return key_event
