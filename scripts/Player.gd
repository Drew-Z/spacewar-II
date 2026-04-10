extends CharacterBody2D
class_name Player

signal health_changed(current_health: int, max_health: int)
signal died

@onready var body_polygon: Polygon2D = $Body

var battle
var move_speed := 260.0
var max_health := 100
var current_health := 100
var fire_cooldown := 0.22
var fire_timer := 0.0
var bullet_damage := 1
var bullet_speed := 700.0
var invulnerability_timer := 0.0
var aim_direction := Vector2.UP
var combat_enabled := true
var alive := true
var secondary_names := ["Missile", "Shockwave"]


func bind_battle(controller) -> void:
	battle = controller


func apply_run_state() -> void:
	move_speed = float(GameState.get_stat("move_speed", move_speed))
	max_health = int(GameState.get_stat("max_health", max_health))
	current_health = int(GameState.get_stat("current_health", current_health))
	fire_cooldown = float(GameState.get_stat("fire_cooldown", fire_cooldown))
	bullet_damage = int(GameState.get_stat("bullet_damage", bullet_damage))
	bullet_speed = float(GameState.get_stat("bullet_speed", bullet_speed))
	emit_signal("health_changed", current_health, max_health)


func set_combat_enabled(enabled: bool) -> void:
	combat_enabled = enabled
	if not enabled:
		velocity = Vector2.ZERO


func is_alive() -> bool:
	return alive


func _physics_process(delta: float) -> void:
	if not alive:
		return

	fire_timer = max(0.0, fire_timer - delta)
	invulnerability_timer = max(0.0, invulnerability_timer - delta)

	if invulnerability_timer > 0.0 and int(invulnerability_timer * 20.0) % 2 == 0:
		body_polygon.color = Color(1.0, 0.55, 0.55, 1.0)
	else:
		body_polygon.color = Color(0.35, 0.95, 1.0, 1.0)

	if not combat_enabled:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	var input_vector := _read_move_input()
	if input_vector != Vector2.ZERO:
		aim_direction = input_vector.normalized()

	velocity = input_vector * move_speed
	move_and_slide()

	if battle != null:
		var rect: Rect2 = battle.get_playfield_rect()
		global_position = global_position.clamp(rect.position, rect.position + rect.size)

	if Input.is_key_pressed(KEY_SPACE):
		_try_fire_primary()


func _unhandled_input(event: InputEvent) -> void:
	if not alive or not combat_enabled:
		return
	if event is InputEventKey and event.pressed and not event.echo:
		match event.physical_keycode:
			KEY_Q:
				_switch_secondary()
			KEY_E:
				_use_secondary()


func _read_move_input() -> Vector2:
	var move := Vector2.ZERO
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
		move.x -= 1.0
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		move.x += 1.0
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
		move.y -= 1.0
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		move.y += 1.0
	return move.normalized()


func _try_fire_primary() -> void:
	if fire_timer > 0.0 or battle == null:
		return

	fire_timer = fire_cooldown
	var direction: Vector2 = battle.get_primary_direction(global_position, aim_direction)
	aim_direction = direction
	battle.spawn_player_projectile(
		global_position + direction * 18.0,
		direction,
		bullet_speed,
		bullet_damage,
		Color(0.45, 1.0, 1.0, 1.0),
		5.0
	)


func _switch_secondary() -> void:
	var current_index := int(GameState.get_stat("secondary_index", 0))
	current_index = (current_index + 1) % secondary_names.size()
	GameState.set_stat("secondary_index", current_index)


func _use_secondary() -> void:
	if battle == null:
		return

	match int(GameState.get_stat("secondary_index", 0)):
		0:
			var ammo := int(GameState.get_stat("missile_ammo", 0))
			if ammo <= 0:
				return
			GameState.set_stat("missile_ammo", ammo - 1)
			var direction: Vector2 = battle.get_primary_direction(global_position, aim_direction)
			aim_direction = direction
			battle.spawn_player_projectile(
				global_position + direction * 16.0,
				direction,
				bullet_speed * 0.8,
				bullet_damage + 2,
				Color(1.0, 0.68, 0.32, 1.0),
				8.0
			)
		1:
			var bombs := int(GameState.get_stat("bomb_charges", 0))
			if bombs <= 0:
				return
			GameState.set_stat("bomb_charges", bombs - 1)
			battle.trigger_shockwave(global_position, 150.0, bullet_damage + 2)


func get_primary_status_text() -> String:
	if fire_timer <= 0.0:
		return "Primary READY"
	var progress := clampf(1.0 - fire_timer / fire_cooldown, 0.0, 1.0)
	return "Primary Cooldown %d%%" % int(progress * 100.0)


func get_secondary_status_text() -> String:
	var current_index := int(GameState.get_stat("secondary_index", 0))
	if current_index == 0:
		return "%s %d / %d" % [
			secondary_names[current_index],
			int(GameState.get_stat("missile_ammo", 0)),
			int(GameState.get_stat("max_missile_ammo", 0))
		]
	return "%s %d / %d" % [
		secondary_names[current_index],
		int(GameState.get_stat("bomb_charges", 0)),
		int(GameState.get_stat("max_bomb_charges", 0))
	]


func take_damage(amount: int) -> void:
	if not alive or invulnerability_timer > 0.0:
		return

	current_health = max(current_health - amount, 0)
	GameState.set_stat("current_health", current_health)
	health_changed.emit(current_health, max_health)
	invulnerability_timer = 0.45

	if current_health <= 0:
		alive = false
		combat_enabled = false
		died.emit()
