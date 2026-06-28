extends SceneTree


func _initialize() -> void:
	_run_test()


func _run_test() -> void:
	print("SmokeTest: start")
	var game_state := root.get_node_or_null("GameState")
	if game_state == null:
		printerr("GameState autoload was not found.")
		quit(1)
		return

	var error := change_scene_to_file("res://scenes/NokiaMenu.tscn")
	if error != OK:
		printerr("Failed to load main menu.")
		quit(1)
		return

	if not await _wait_for_scene("res://scenes/NokiaMenu.tscn", 2.0):
		printerr("Main menu did not load in time.")
		quit(1)
		return
	print("SmokeTest: menu loaded")
	var menu := current_scene
	if menu == null or not menu.has_method("start_game"):
		printerr("Main menu is missing start logic.")
		quit(1)
		return
	menu.start_game()

	if not await _wait_for_scene("res://scenes/NokiaBattle.tscn", 2.0):
		printerr("Battle scene did not load in time.")
		quit(1)
		return
	print("SmokeTest: battle loaded")
	var battle := current_scene
	if battle == null:
		printerr("Battle scene did not load correctly.")
		quit(1)
		return

	await create_timer(1.5).timeout
	battle.debug_force_result(true)
	await create_timer(0.5).timeout
	print("SmokeTest: waited for result")

	if current_scene == null or current_scene.scene_file_path != "res://scenes/NokiaResult.tscn":
		printerr("Result scene did not open after player death.")
		quit(1)
		return

	var run: Dictionary = game_state.last_run
	if int(run.get("enemies_destroyed", 0)) < 0:
		printerr("Enemy count not recorded.")
		quit(1)
		return

	print("Smoke test passed: menu -> nokia battle -> result")
	quit()


func _wait_for_scene(target_path: String, timeout: float) -> bool:
	var elapsed := 0.0
	while elapsed < timeout:
		await create_timer(0.05).timeout
		if current_scene != null and current_scene.scene_file_path == target_path:
			return true
		elapsed += 0.05
	return false
