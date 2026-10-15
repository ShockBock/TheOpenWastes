extends SceneTree

## Plays the main game scene for a few seconds and checks that the world was
## built: terrain, buildings, the player standing on the ground, and an enemy.
## Exits with code 1 on failure. Run with:
##   godot --headless --path . -s res://tools/ci/smoke_test.gd

const MAIN_SCENE: String = "res://main/the_open_wastes.tscn"
const FRAMES_TO_RUN: int = 180


func _initialize() -> void:
	change_scene_to_file(MAIN_SCENE)
	for i in FRAMES_TO_RUN:
		await physics_frame

	var failures: PackedStringArray = []
	var main: Node = current_scene
	if main == null or main.scene_file_path != MAIN_SCENE:
		failures.append("Main scene did not load")
	else:
		var terrain: Node = main.get_node("MAIN_SEQUENCE/TerrainGenerator")
		if terrain.chunks.size() == 0:
			failures.append("No terrain chunks were generated")
		var buildings: int = main.get_node("MAIN_SEQUENCE/BuildingSpawner").get_child_count()
		if buildings == 0:
			failures.append("No buildings were placed")
		var player: CharacterBody3D = get_first_node_in_group("player") as CharacterBody3D
		if player == null:
			failures.append("Player was not spawned")
		elif not player.is_on_floor():
			failures.append(
				"Player is not standing on the ground (y = %.1f)" % player.global_position.y
			)
		if get_nodes_in_group("enemy").is_empty():
			failures.append("No enemies were spawned")
		print("Terrain chunks: %d, buildings: %d" % [terrain.chunks.size(), buildings])

	for failure: String in failures:
		printerr(failure)
	print("Smoke test " + ("failed" if failures.size() > 0 else "passed"))
	quit(1 if failures.size() > 0 else 0)
