extends SceneTree

const OUTPUT_DIR := "D:/workspace4Cursor/game/blog/public/images/projects"
const OUTPUT_PREFIX := "spacewar-ii"
const MENU_SCENE := "res://scenes/NokiaMenu.tscn"
const BATTLE_SCENE := "res://scenes/NokiaBattle.tscn"
const RESULT_SCENE := "res://scenes/NokiaResult.tscn"

var game_state: Node


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var mkdir_error := DirAccess.make_dir_recursive_absolute(OUTPUT_DIR)
	if mkdir_error != OK and mkdir_error != ERR_ALREADY_EXISTS:
		push_error("Failed to create screenshot output dir: %s" % mkdir_error)
		quit(1)
		return

	root.size = Vector2i(960, 540)
	game_state = root.get_node_or_null("GameState")
	if game_state == null:
		push_error("GameState autoload was not found.")
		quit(1)
		return

	await _capture_menu()
	await _capture_battle()
	await _capture_result()
	quit()


func _capture_menu() -> void:
	await change_scene_to_file(MENU_SCENE)
	await _settle_frames(20)
	await _save_viewport("%s-menu.png" % OUTPUT_PREFIX)


func _capture_battle() -> void:
	await change_scene_to_file(BATTLE_SCENE)
	await _settle_frames(80)
	var battle := current_scene
	if battle != null:
		battle.stage = 2
		battle.distance = 720.0
		game_state.set_stat("current_stage", 2)
		game_state.set_stat("score", 7200)
		game_state.set_stat("weapon_level", 3)
		game_state.set_stat("bombs", 2)
		game_state.set_stat("enemies_destroyed", 18)
		battle.chain_count = 5
		battle.best_chain = 8
		battle.chain_bonus_score = 420
		game_state.set_stat("best_chain", 8)
		game_state.set_stat("chain_bonus_score", 420)
		if battle.has_method("_start_boss_phase"):
			battle.call("_start_boss_phase")
		if battle.has_method("spawn_boss_shot"):
			battle.call("spawn_boss_shot", Vector2(515.0, 146.0))
		_spawn_showcase_enemy(battle, "tank", Vector2(270.0, 232.0))
		_spawn_showcase_enemy(battle, "sweeper", Vector2(510.0, 194.0))
		_spawn_showcase_enemy(battle, "diver", Vector2(710.0, 252.0))
		if battle.has_method("_refresh_hud"):
			battle.call("_refresh_hud")
	await _settle_frames(12)
	await _save_viewport("%s-battle.png" % OUTPUT_PREFIX)


func _capture_result() -> void:
	game_state.begin_run()
	game_state.set_stat("result_victory", true)
	game_state.set_stat("score", 18450)
	game_state.set_stat("current_stage", 3)
	game_state.set_stat("total_stages", 3)
	game_state.set_stat("enemies_destroyed", 42)
	game_state.set_stat("pickups_collected", 8)
	game_state.set_stat("distance", 3600.0)
	game_state.set_stat("best_chain", 11)
	game_state.set_stat("chain_bonus_score", 860)
	game_state.set_stat("stage_clear_bonus", 4620)
	game_state.finish_run()
	await change_scene_to_file(RESULT_SCENE)
	await _settle_frames(24)
	await _save_viewport("%s-result.png" % OUTPUT_PREFIX)


func _spawn_showcase_enemy(battle: Node, enemy_type: String, position: Vector2) -> void:
	var enemy_scene: PackedScene = load("res://scenes/NokiaEnemy.tscn")
	var enemy_layer := battle.get_node_or_null("EnemyLayer")
	if enemy_scene == null or enemy_layer == null:
		return
	var enemy := enemy_scene.instantiate()
	enemy.global_position = position
	enemy_layer.add_child(enemy)
	enemy.call("configure", {
		"enemy_type": enemy_type,
		"speed": 10.0,
		"health": 999,
		"contact_damage": 14,
		"fire_cooldown": 1.2,
		"wave_amplitude": 42.0,
		"wave_frequency": 2.6,
		"wave_phase": 0.0
	}, battle)


func _settle_frames(frame_count: int) -> void:
	for _index in range(frame_count):
		await process_frame


func _save_viewport(file_name: String) -> void:
	await process_frame
	var image := root.get_texture().get_image()
	var path := "%s/%s" % [OUTPUT_DIR, file_name]
	var error := image.save_png(path)
	if error != OK:
		push_error("Failed to save screenshot %s: %s" % [path, error])
