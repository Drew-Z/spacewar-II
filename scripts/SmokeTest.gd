extends SceneTree


func _initialize() -> void:
	call_deferred("_run_test")


func _run_test() -> void:
	var game_state := root.get_node_or_null("GameState")
	if game_state == null:
		printerr("GameState autoload was not found.")
		quit(1)
		return

	var error := change_scene_to_file("res://scenes/MainMenu.tscn")
	if error != OK:
		printerr("Failed to load main menu.")
		quit(1)
		return

	await scene_changed
	await process_frame
	var menu := current_scene
	if menu == null or not menu.has_method("start_game"):
		printerr("Main menu is missing start logic.")
		quit(1)
		return
	menu.start_game()

	await scene_changed
	await process_frame
	var battle := current_scene
	if battle == null or not battle.has_method("debug_force_clear_wave"):
		printerr("Battle scene did not load correctly.")
		quit(1)
		return

	for _wave_index in range(3):
		battle.debug_force_clear_wave()
		await process_frame
		await process_frame
		if not battle.upgrade_overlay.visible:
			printerr("Upgrade selection did not appear after wave clear.")
			quit(1)
			return
		battle.debug_select_first_upgrade()
		await process_frame
		await process_frame

	battle.player.take_damage(9999)
	await create_timer(1.2).timeout

	if current_scene == null or current_scene.scene_file_path != "res://scenes/ResultScene.tscn":
		printerr("Result scene did not open after player death.")
		quit(1)
		return

	var run: Dictionary = game_state.last_run
	if int(run.get("survived_waves", 0)) < 3:
		printerr("Survived waves is below 3.")
		quit(1)
		return
	if int(run.get("kills", 0)) <= 0:
		printerr("Kill count did not increase.")
		quit(1)
		return
	if (run.get("selected_upgrades", []) as Array).size() < 3:
		printerr("Upgrade history did not record 3 picks.")
		quit(1)
		return

	print("Smoke test passed: menu -> battle -> 3 waves -> upgrades -> result")
	quit()
