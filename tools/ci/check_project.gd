extends SceneTree

## Loads every script and scene in the project and exits with code 1 if any
## fail to load, compile or instantiate. Run with:
##   godot --headless --path . -s res://tools/ci/check_project.gd

var failures: PackedStringArray = []


func _initialize() -> void:
	var scripts: int = 0
	var scenes: int = 0
	for path: String in _find_files("res://"):
		if path.ends_with(".gd"):
			scripts += 1
			var script: GDScript = load(path) as GDScript
			if script == null or not script.can_instantiate():
				failures.append("Script failed to compile: " + path)
		elif path.ends_with(".tscn"):
			scenes += 1
			var scene: PackedScene = load(path) as PackedScene
			if scene == null:
				failures.append("Scene failed to load: " + path)
				continue
			var instance: Node = scene.instantiate()
			if instance == null:
				failures.append("Scene failed to instantiate: " + path)
			else:
				instance.free()

	print("Checked %d scripts and %d scenes." % [scripts, scenes])
	for failure: String in failures:
		printerr(failure)
	quit(1 if failures.size() > 0 else 0)


func _find_files(dir: String) -> PackedStringArray:
	var found: PackedStringArray = []
	for sub: String in DirAccess.get_directories_at(dir):
		if not sub.begins_with("."):
			found.append_array(_find_files(dir.path_join(sub)))
	for file: String in DirAccess.get_files_at(dir):
		found.append(dir.path_join(file))
	return found
