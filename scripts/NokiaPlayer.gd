extends CharacterBody2D
class_name NokiaPlayer

signal health_changed(current_health: int, max_health: int)
signal died
signal bomb_used

@onready var body_polygon: Polygon2D = $Body

var battle
var move_speed := 260.0
var max_health := 100
var current_health := 100
var fire_cooldown := 0.18
var fire_timer := 0.0
var weapon_level := 1
var invulnerability_timer := 0.0
var alive := true


func bind_battle(controller) -> void:
	battle = controller


func apply_run_state() -> void:
	move_speed = float(GameState.get_stat("move_speed", move_speed))
	max_health = int(GameState.get_stat("max_health", max_health))
	current_health = int(GameState.get_stat("current_health", current_health))
	fire_cooldown = float(GameState.get_stat("fire_cooldown", fire_cooldown))
	weapon_level = int(GameState.get_stat("weapon_level", weapon_level))
	health_changed.emit(current_health, max_health)


func _physics_process(delta: float) -> void:
	if not alive:
		return

	fire_timer = max(0.0, fire_timer - delta)
	invulnerability_timer = max(0.0, invulnerability_timer - delta)

	if invulnerability_timer > 0.0 and int(invulnerability_timer * 20.0) % 2 == 0:
		body_polygon.color = Color(1.0, 0.6, 0.6, 1.0)
	else:
		body_polygon.color = Color(0.4, 1.0, 0.9, 1.0)

	var input_vector := _read_move_input()
	velocity = input_vector * move_speed
	move_and_slide()

	if battle != null:
		var rect: Rect2 = battle.get_playfield_rect()
		global_position = global_position.clamp(rect.position, rect.position + rect.size)

	if Input.is_key_pressed(KEY_SPACE):
		_try_fire_primary()


func _unhandled_input(event: InputEvent) -> void:
	if not alive:
		return
	if event is InputEventKey and event.pressed and not event.echo:
		if event.physical_keycode == KEY_X:
			_use_bomb()


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
	battle.spawn_player_burst(global_position, weapon_level)


func _use_bomb() -> void:
	if battle == null:
		return
	var bombs := int(GameState.get_stat("bombs", 0))
	if bombs <= 0:
		return
	GameState.set_stat("bombs", bombs - 1)
	battle.trigger_player_bomb(global_position)
	bomb_used.emit()


func take_damage(amount: int) -> void:
	if not alive or invulnerability_timer > 0.0:
		return
	current_health = max(current_health - amount, 0)
	GameState.set_stat("current_health", current_health)
	health_changed.emit(current_health, max_health)
	invulnerability_timer = 0.55
	if current_health <= 0:
		alive = false
		died.emit()


func revive() -> void:
	alive = true
	current_health = max_health
	GameState.set_stat("current_health", current_health)
	invulnerability_timer = 1.2
	health_changed.emit(current_health, max_health)
