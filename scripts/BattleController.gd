extends Node2D

const PLAYFIELD := Rect2(40.0, 40.0, 880.0, 460.0)
const WaveDirectorScript = preload("res://scripts/WaveDirector.gd")
const UpgradeManagerScript = preload("res://scripts/UpgradeManager.gd")

var enemy_scene := preload("res://scenes/Enemy.tscn")
var projectile_scene := preload("res://scenes/Projectile.tscn")
var shockwave_scene := preload("res://scenes/ShockwaveEffect.tscn")
var wave_director = WaveDirectorScript.new()
var upgrade_manager = UpgradeManagerScript.new()

@onready var player = $Player
@onready var gravity_star = $GravityStar
@onready var enemy_layer: Node2D = $EnemyLayer
@onready var projectile_layer: Node2D = $ProjectileLayer
@onready var effect_layer: Node2D = $EffectLayer
@onready var spawn_timer: Timer = $SpawnTimer
@onready var hud = $HUD
@onready var upgrade_overlay = $UpgradeOverlay

var current_wave := 0
var remaining_to_spawn := 0
var active_enemies := 0
var current_wave_config: Dictionary = {}
var spawn_queue: Array = []


func _ready() -> void:
	randomize()
	GameState.begin_run()

	player.bind_battle(self)
	player.health_changed.connect(_on_player_health_changed)
	player.died.connect(_on_player_died)
	player.apply_run_state()
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	upgrade_overlay.upgrade_selected.connect(_on_upgrade_selected)

	_refresh_hud()
	_start_wave(1)


func _process(_delta: float) -> void:
	hud.set_wave(GameState.get_stat("current_wave", 1), active_enemies, remaining_to_spawn)
	hud.set_primary_status(player.get_primary_status_text())
	hud.set_secondary_status(player.get_secondary_status_text())
	hud.set_systems_status(player.get_system_status_text())


func get_playfield_rect() -> Rect2:
	return PLAYFIELD


func get_gravity_vector(position: Vector2) -> Vector2:
	var offset: Vector2 = gravity_star.global_position - position
	var distance_squared: float = max(offset.length_squared(), 3600.0)
	var pull_strength: float = gravity_star.gravity_strength / distance_squared
	return offset.normalized() * min(pull_strength, 120.0)


func is_in_star_danger(position: Vector2) -> bool:
	return position.distance_to(gravity_star.global_position) <= gravity_star.danger_radius


func get_star_damage() -> int:
	var resistance := float(GameState.get_stat("star_resistance", 0.0))
	return max(4, int(round(gravity_star.contact_damage * (1.0 - resistance))))


func get_hyperspace_failure_risk() -> float:
	var uses := int(GameState.get_stat("hyperspace_uses", 0))
	var stability := float(GameState.get_stat("hyperspace_stability", 0.0))
	return clampf(0.08 + uses * 0.11 - stability, 0.04, 0.55)


func get_primary_direction(origin: Vector2, fallback_direction: Vector2) -> Vector2:
	var closest_enemy = null
	var closest_distance := INF
	for enemy in enemy_layer.get_children():
		if not enemy.has_method("take_damage"):
			continue
		var distance := origin.distance_squared_to(enemy.global_position)
		if distance < closest_distance:
			closest_distance = distance
			closest_enemy = enemy

	if closest_enemy != null:
		return (closest_enemy.global_position - origin).normalized()
	if fallback_direction != Vector2.ZERO:
		return fallback_direction.normalized()
	return Vector2.UP


func spawn_player_projectile(
	origin: Vector2,
	direction: Vector2,
	speed: float,
	damage: int,
	tint: Color,
	radius: float
) -> void:
	var projectile = projectile_scene.instantiate()
	projectile.setup(origin, direction, speed, damage, tint, radius, "player")
	projectile_layer.add_child(projectile)


func trigger_shockwave(origin: Vector2, radius: float, damage: int) -> void:
	var effect := shockwave_scene.instantiate()
	effect.global_position = origin
	effect.configure(radius)
	effect_layer.add_child(effect)

	for enemy in enemy_layer.get_children():
		if not enemy.has_method("take_damage"):
			continue
		if enemy.global_position.distance_to(origin) <= radius:
			enemy.take_damage(damage)


func debug_force_clear_wave() -> void:
	var pending_kills := remaining_to_spawn
	remaining_to_spawn = 0
	spawn_queue.clear()
	spawn_timer.stop()
	for enemy in enemy_layer.get_children():
		if enemy.has_method("take_damage"):
			enemy.take_damage(999)
	for _index in range(pending_kills):
		GameState.add_kill()
	if active_enemies <= 0 and not upgrade_overlay.visible:
		_enter_upgrade_phase()


func debug_select_first_upgrade() -> void:
	upgrade_overlay.debug_pick_first()


func debug_trigger_hyperspace() -> void:
	try_player_hyperspace()


func debug_force_player_death() -> void:
	player.invulnerability_timer = 0.0
	player.take_damage(9999)


func _start_wave(wave_number: int) -> void:
	current_wave = wave_number
	GameState.set_stat("current_wave", current_wave)
	current_wave_config = wave_director.build_wave(current_wave)
	spawn_queue = (current_wave_config.get("spawn_queue", []) as Array).duplicate(true)
	remaining_to_spawn = spawn_queue.size()
	active_enemies = 0

	player.set_combat_enabled(true)
	hud.show_message("Wave %d Start" % current_wave)
	spawn_timer.wait_time = float(current_wave_config.get("spawn_interval", 0.5))
	spawn_timer.start()
	_refresh_hud()


func _spawn_enemy() -> void:
	if spawn_queue.is_empty():
		return

	var enemy_data: Dictionary = spawn_queue.pop_front()
	var enemy = enemy_scene.instantiate()
	enemy.global_position = _get_spawn_position()
	enemy_layer.add_child(enemy)
	var enemy_config := current_wave_config.duplicate(true)
	for key in enemy_data.keys():
		enemy_config[key] = enemy_data[key]
	enemy.configure(enemy_config, player, self)
	enemy.defeated.connect(_on_enemy_defeated)
	active_enemies += 1


func _get_spawn_position() -> Vector2:
	for _attempt in range(10):
		var edge := randi_range(0, 3)
		var candidate := Vector2.ZERO
		match edge:
			0:
				candidate = Vector2(randf_range(PLAYFIELD.position.x, PLAYFIELD.end.x), PLAYFIELD.position.y)
			1:
				candidate = Vector2(randf_range(PLAYFIELD.position.x, PLAYFIELD.end.x), PLAYFIELD.end.y)
			2:
				candidate = Vector2(PLAYFIELD.position.x, randf_range(PLAYFIELD.position.y, PLAYFIELD.end.y))
			_:
				candidate = Vector2(PLAYFIELD.end.x, randf_range(PLAYFIELD.position.y, PLAYFIELD.end.y))
		if candidate.distance_to(gravity_star.global_position) > gravity_star.safe_spawn_radius:
			return candidate
	return PLAYFIELD.get_center() + Vector2(0, 180)


func get_safe_hyperspace_position() -> Vector2:
	for _attempt in range(20):
		var candidate := Vector2(
			randf_range(PLAYFIELD.position.x + 32.0, PLAYFIELD.end.x - 32.0),
			randf_range(PLAYFIELD.position.y + 32.0, PLAYFIELD.end.y - 32.0)
		)
		if candidate.distance_to(gravity_star.global_position) <= gravity_star.safe_spawn_radius:
			continue
		var blocked := false
		for enemy in enemy_layer.get_children():
			if candidate.distance_to(enemy.global_position) < 56.0:
				blocked = true
				break
		if not blocked:
			return candidate
	return PLAYFIELD.get_center() + Vector2(0, 160)


func try_player_hyperspace() -> void:
	if upgrade_overlay.visible or not player.is_alive():
		return

	var charges := int(GameState.get_stat("hyperspace_charges", 0))
	if charges <= 0:
		hud.show_message("No Hyper Charges")
		return

	var failure_risk := get_hyperspace_failure_risk()
	GameState.set_stat("hyperspace_charges", charges - 1)
	GameState.set_stat("hyperspace_uses", int(GameState.get_stat("hyperspace_uses", 0)) + 1)
	player.global_position = get_safe_hyperspace_position()

	if randf() < failure_risk:
		hud.show_message("Hyper Exit Unstable")
		player.take_damage(35)
	else:
		hud.show_message("Hyperspace Jump")
		player.grant_invulnerability(0.9)


func _enter_upgrade_phase() -> void:
	GameState.record_wave_cleared(current_wave)
	player.set_combat_enabled(false)
	spawn_timer.stop()
	hud.show_message("Wave %d Clear" % current_wave)
	upgrade_overlay.present_choices(upgrade_manager.get_choices())


func _refresh_hud() -> void:
	hud.set_health(player.current_health, player.max_health)
	hud.set_wave(GameState.get_stat("current_wave", 1), active_enemies, remaining_to_spawn)
	hud.set_primary_status(player.get_primary_status_text())
	hud.set_secondary_status(player.get_secondary_status_text())
	hud.set_systems_status(player.get_system_status_text())


func _on_spawn_timer_timeout() -> void:
	if remaining_to_spawn <= 0 or spawn_queue.is_empty():
		spawn_timer.stop()
		return

	remaining_to_spawn -= 1
	_spawn_enemy()
	if remaining_to_spawn <= 0:
		spawn_timer.stop()


func _on_enemy_defeated(_enemy) -> void:
	active_enemies = max(active_enemies - 1, 0)
	GameState.add_kill()
	if remaining_to_spawn <= 0 and active_enemies <= 0 and not upgrade_overlay.visible and player.is_alive():
		_enter_upgrade_phase()


func _on_upgrade_selected(upgrade_data: Dictionary) -> void:
	GameState.apply_upgrade(upgrade_data["id"])
	GameState.remember_upgrade(upgrade_data["name"])
	upgrade_overlay.hide()
	player.apply_run_state()
	_refresh_hud()
	_start_wave(current_wave + 1)


func _on_player_health_changed(current_health: int, max_health: int) -> void:
	hud.set_health(current_health, max_health)


func _on_player_died() -> void:
	spawn_timer.stop()
	player.set_combat_enabled(false)
	for enemy in enemy_layer.get_children():
		if enemy.has_method("freeze"):
			enemy.freeze()

	GameState.set_stat("current_health", 0)
	GameState.finish_run()
	hud.show_message("Hull Breach")
	await get_tree().create_timer(0.9).timeout
	get_tree().change_scene_to_file(GameState.RESULT_SCENE)
