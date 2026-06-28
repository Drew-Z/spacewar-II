extends Node2D

const PLAYFIELD := Rect2(48.0, 48.0, 864.0, 444.0)
const CHAIN_WINDOW_SECONDS := 1.25
const CHAIN_BONUS_STEP := 35
const CHAIN_BONUS_CAP := 260

var enemy_scene: PackedScene = preload("res://scenes/NokiaEnemy.tscn")
var boss_scene: PackedScene = preload("res://scenes/NokiaBoss.tscn")
var projectile_scene: PackedScene = preload("res://scenes/NokiaProjectile.tscn")
var pickup_scene: PackedScene = preload("res://scenes/NokiaPickup.tscn")

@onready var player = $Player
@onready var enemy_layer: Node2D = $EnemyLayer
@onready var projectile_layer: Node2D = $ProjectileLayer
@onready var pickup_layer: Node2D = $PickupLayer
@onready var hud: CanvasLayer = $HUD
@onready var spawn_timer: Timer = $SpawnTimer
@onready var pickup_timer: Timer = $PickupTimer

var stage_length := 1200.0
var scroll_speed := 140.0
var distance := 0.0
var stage := 1
var running := true
var boss_active := false
var total_stages := 3
var chain_count := 0
var best_chain := 0
var chain_timer := 0.0
var chain_bonus_score := 0


func _ready() -> void:
	randomize()
	GameState.begin_run()
	total_stages = int(GameState.get_stat("total_stages", total_stages))
	player.bind_battle(self)
	player.health_changed.connect(_on_player_health_changed)
	player.died.connect(_on_player_died)
	player.bomb_used.connect(_on_bomb_used)
	player.apply_run_state()
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	pickup_timer.timeout.connect(_on_pickup_timer_timeout)
	_refresh_hud()


func _process(delta: float) -> void:
	if not running:
		return
	distance += scroll_speed * delta
	GameState.set_stat("distance", distance)
	hud.set_stage(stage, distance, stage_length, total_stages)
	_tick_chain(delta)
	_update_hud_meters()
	if distance >= stage_length and not boss_active:
		_start_boss_phase()
	_update_spawn_pacing()


func get_playfield_rect() -> Rect2:
	return PLAYFIELD


func spawn_player_burst(origin: Vector2, weapon_level: int) -> void:
	var shot_speed := float(GameState.get_stat("bullet_speed", 760.0))
	var damage := int(GameState.get_stat("bullet_damage", 1))
	var spread := 0.0
	var bullets := []
	match weapon_level:
		1:
			bullets = [Vector2(0, -1)]
		2:
			bullets = [Vector2(-0.2, -1), Vector2(0.2, -1)]
			spread = 0.2
		3:
			bullets = [Vector2(-0.3, -1), Vector2(0, -1), Vector2(0.3, -1)]
			spread = 0.3
		_:
			bullets = [Vector2(-0.4, -1), Vector2(-0.15, -1), Vector2(0.15, -1), Vector2(0.4, -1)]
			spread = 0.4

	for dir in bullets:
		var projectile = projectile_scene.instantiate()
		projectile.owner_tag = "player"
		projectile_layer.add_child(projectile)
		projectile.call_deferred("setup", origin + Vector2(dir.x * 12.0, -12.0), dir.normalized() * shot_speed, damage, Color(0.4, 1.0, 0.9, 1.0))


func spawn_enemy_shot(origin: Vector2) -> void:
	var projectile = projectile_scene.instantiate()
	projectile.owner_tag = "enemy"
	projectile_layer.add_child(projectile)
	projectile.call_deferred("setup", origin + Vector2(0, 10), Vector2(0, 220.0 + float(stage - 1) * 18.0), 8, Color(1.0, 0.4, 0.4, 1.0))


func spawn_boss_shot(origin: Vector2) -> void:
	var fan := [-0.34, 0.34]
	if stage >= 2:
		fan = [-0.42, 0.0, 0.42]
	if stage >= 3:
		fan = [-0.56, -0.24, 0.0, 0.24, 0.56]
	for horizontal in fan:
		var projectile = projectile_scene.instantiate()
		projectile.owner_tag = "enemy"
		projectile_layer.add_child(projectile)
		var speed := 238.0 + float(stage) * 20.0
		var velocity := Vector2(horizontal, 1.0).normalized() * speed
		projectile.call_deferred("setup", origin + Vector2(horizontal * 22.0, 12.0), velocity, 10, Color(1.0, 0.5, 0.4, 1.0))


func trigger_player_bomb(origin: Vector2) -> void:
	for enemy in enemy_layer.get_children():
		if enemy.has_method("take_damage"):
			enemy.take_damage(999)
	for projectile in projectile_layer.get_children():
		if projectile.get("owner_tag") == "enemy":
			projectile.queue_free()
	GameState.set_stat("score", int(GameState.get_stat("score", 0)) + 300)


func _on_spawn_timer_timeout() -> void:
	if not running:
		return
	if boss_active:
		return
	var config := _build_enemy_config()
	_spawn_enemy(config, Vector2(randf_range(PLAYFIELD.position.x + 24.0, PLAYFIELD.end.x - 24.0), PLAYFIELD.position.y - 30.0))
	_spawn_burst_if_needed()


func _build_enemy_config() -> Dictionary:
	var progress := clampf(distance / stage_length, 0.0, 1.0)
	var roll := randf()
	var enemy_type := "scout"
	var pressure := progress + float(stage - 1) * 0.18
	if pressure > 0.42 and roll < 0.18:
		enemy_type = "sweeper"
	elif pressure > 0.58 and roll > 0.72:
		enemy_type = "diver"
	elif progress > 0.35 and roll > 0.54:
		enemy_type = "tank"
	if progress > 0.7 and roll > 0.42:
		enemy_type = "tank"
	var base_speed := 126.0 + progress * 44.0 + float(stage - 1) * 14.0
	var health := 2
	var contact := 10
	var cooldown := 1.7
	match enemy_type:
		"tank":
			health = 4 + stage
			contact = 16
			cooldown = 1.15
		"diver":
			health = 3 if stage > 2 else 2
			contact = 18
			cooldown = 2.2
		"sweeper":
			health = 3
			contact = 14
			cooldown = 1.45
		_:
			health = 3 if stage >= 3 and progress > 0.55 else 2
			contact = 10
			cooldown = 1.75
	return {
		"enemy_type": enemy_type,
		"speed": base_speed + randf_range(-15.0, 15.0),
		"health": health,
		"contact_damage": contact,
		"fire_cooldown": cooldown,
		"wave_amplitude": 30.0 + progress * 34.0,
		"wave_frequency": 2.2 + progress * 1.5,
		"wave_phase": randf() * TAU
	}


func _on_pickup_timer_timeout() -> void:
	if not running:
		return
	if boss_active:
		return
	var pickup = pickup_scene.instantiate()
	pickup.global_position = Vector2(randf_range(PLAYFIELD.position.x + 32.0, PLAYFIELD.end.x - 32.0), PLAYFIELD.position.y - 40.0)
	pickup_layer.add_child(pickup)
	pickup.call_deferred("configure", "bomb" if randf() > 0.65 else "weapon")


func _on_enemy_defeated(enemy) -> void:
	GameState.add_kill()
	var bonus_score := _register_chain_bonus()
	if enemy.enemy_type == "tank":
		bonus_score += 80
	elif enemy.enemy_type == "diver":
		bonus_score += 55
	elif enemy.enemy_type == "sweeper":
		bonus_score += 65
	GameState.set_stat("score", int(GameState.get_stat("score", 0)) + bonus_score)
	_sync_chain_stats()
	_update_hud_meters()


func _on_player_health_changed(current_health: int, max_health: int) -> void:
	hud.set_health(current_health, max_health)
	hud.set_score(int(GameState.get_stat("score", 0)))
	hud.set_lives(int(GameState.get_stat("lives", 0)))
	hud.set_weapon_level(int(GameState.get_stat("weapon_level", 1)))
	hud.set_bombs(int(GameState.get_stat("bombs", 0)))


func _on_bomb_used() -> void:
	hud.set_bombs(int(GameState.get_stat("bombs", 0)))


func _on_player_died() -> void:
	var lives := int(GameState.get_stat("lives", 0)) - 1
	GameState.set_stat("lives", lives)
	if lives > 0:
		chain_count = 0
		chain_timer = 0.0
		_sync_chain_stats()
		player.revive()
		hud.set_lives(lives)
		return
	_finish_stage(false)


func _finish_stage(victory: bool) -> void:
	running = false
	spawn_timer.stop()
	pickup_timer.stop()
	GameState.set_stat("result_victory", victory)
	GameState.finish_run()
	get_tree().change_scene_to_file(GameState.RESULT_SCENE)


func debug_force_result(victory: bool) -> void:
	GameState.set_stat("result_victory", victory)
	GameState.finish_run()
	get_tree().change_scene_to_file(GameState.RESULT_SCENE)


func _refresh_hud() -> void:
	hud.set_score(int(GameState.get_stat("score", 0)))
	hud.set_lives(int(GameState.get_stat("lives", 0)))
	hud.set_health(int(GameState.get_stat("current_health", 0)), int(GameState.get_stat("max_health", 0)))
	hud.set_weapon_level(int(GameState.get_stat("weapon_level", 1)))
	hud.set_bombs(int(GameState.get_stat("bombs", 0)))
	hud.set_stage(stage, distance, stage_length, total_stages)


func _start_boss_phase() -> void:
	boss_active = true
	spawn_timer.stop()
	pickup_timer.stop()
	var boss = boss_scene.instantiate()
	boss.global_position = Vector2(PLAYFIELD.position.x + PLAYFIELD.size.x / 2.0, PLAYFIELD.position.y + 80.0)
	boss.call_deferred("configure", self, {
		"stage": stage,
		"health": 54 + stage * 22,
		"move_speed": 72.0 + float(stage) * 12.0,
		"fire_cooldown": max(0.46, 0.86 - float(stage) * 0.10)
	})
	boss.defeated.connect(_on_boss_defeated)
	enemy_layer.add_child(boss)


func _on_boss_defeated() -> void:
	_award_stage_clear_bonus()
	if stage >= total_stages:
		_finish_stage(true)
		return
	stage += 1
	GameState.set_stat("current_stage", stage)
	var carried_weapon := mini(int(GameState.get_stat("weapon_level", 1)) + 1, 4)
	GameState.set_stat("weapon_level", carried_weapon)
	GameState.set_stat("bombs", mini(int(GameState.get_stat("bombs", 0)) + 1, 3))
	distance = 0.0
	boss_active = false
	_clear_enemy_projectiles()
	_refresh_hud()
	spawn_timer.start()
	pickup_timer.start()


func _update_spawn_pacing() -> void:
	if boss_active:
		return
	var progress := clampf(distance / stage_length, 0.0, 1.0)
	if progress < 0.2:
		spawn_timer.wait_time = 0.85
	elif progress < 0.5:
		spawn_timer.wait_time = 0.7
	elif progress < 0.8:
		spawn_timer.wait_time = 0.55
	else:
		spawn_timer.wait_time = 0.45


func _spawn_burst_if_needed() -> void:
	var progress := clampf(distance / stage_length, 0.0, 1.0)
	if progress < 0.35:
		return
	if randf() > 0.30 + float(stage) * 0.06:
		return
	var burst_count := 2 + int(stage >= 2 and progress > 0.55)
	var center_x := randf_range(PLAYFIELD.position.x + 100.0, PLAYFIELD.end.x - 100.0)
	var lane_spacing := 58.0
	for index in range(burst_count):
		var config := _build_enemy_config()
		if progress < 0.65:
			config["enemy_type"] = "scout"
			config["health"] = 2
		var x_offset := (float(index) - float(burst_count - 1) * 0.5) * lane_spacing
		_spawn_enemy(
			config,
			Vector2(
				clampf(center_x + x_offset, PLAYFIELD.position.x + 28.0, PLAYFIELD.end.x - 28.0),
				PLAYFIELD.position.y - 30.0 - float(index) * 22.0
			)
		)


func _update_hud_meters() -> void:
	hud.set_score(int(GameState.get_stat("score", 0)))
	hud.set_lives(int(GameState.get_stat("lives", 0)))
	hud.set_weapon_level(int(GameState.get_stat("weapon_level", 1)))
	hud.set_bombs(int(GameState.get_stat("bombs", 0)))
	hud.set_chain(chain_count, best_chain, chain_bonus_score)


func _spawn_enemy(config: Dictionary, spawn_position: Vector2) -> void:
	var enemy = enemy_scene.instantiate()
	enemy.global_position = spawn_position
	enemy_layer.add_child(enemy)
	enemy.call_deferred("configure", config, self)
	enemy.defeated.connect(_on_enemy_defeated)


func _clear_enemy_projectiles() -> void:
	for projectile in projectile_layer.get_children():
		if projectile.get("owner_tag") == "enemy":
			projectile.queue_free()


func _tick_chain(delta: float) -> void:
	if chain_timer <= 0.0:
		return
	chain_timer = maxf(chain_timer - delta, 0.0)
	if chain_timer <= 0.0:
		chain_count = 0
		_update_hud_meters()


func _register_chain_bonus() -> int:
	if chain_timer > 0.0:
		chain_count += 1
	else:
		chain_count = 1
	chain_timer = CHAIN_WINDOW_SECONDS
	best_chain = maxi(best_chain, chain_count)
	if chain_count < 3:
		return 0
	var bonus := mini((chain_count - 2) * CHAIN_BONUS_STEP, CHAIN_BONUS_CAP)
	chain_bonus_score += bonus
	return bonus


func _award_stage_clear_bonus() -> void:
	var base_bonus := 1000 + stage * 420
	var resource_bonus := int(GameState.get_stat("lives", 0)) * 150 + int(GameState.get_stat("bombs", 0)) * 120
	var weapon_bonus := int(GameState.get_stat("weapon_level", 1)) * 85
	var total_bonus := base_bonus + resource_bonus + weapon_bonus
	GameState.set_stat("stage_clear_bonus", int(GameState.get_stat("stage_clear_bonus", 0)) + total_bonus)
	GameState.set_stat("score", int(GameState.get_stat("score", 0)) + total_bonus)
	_sync_chain_stats()


func _sync_chain_stats() -> void:
	GameState.set_stat("best_chain", best_chain)
	GameState.set_stat("chain_bonus_score", chain_bonus_score)
