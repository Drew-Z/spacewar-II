extends CharacterBody2D
class_name Enemy

signal defeated(enemy)

@onready var body_polygon: Polygon2D = $Body

var battle
var move_speed := 100.0
var health := 2
var contact_damage := 10
var target
var attack_cooldown := 0.75
var attack_timer := 0.0
var alive := true
var enemy_type := "hunter"
var dash_timer := 0.0
var dash_cooldown := 0.0
var dash_direction := Vector2.ZERO


func configure(config: Dictionary, target_player, battle_controller) -> void:
	battle = battle_controller
	move_speed = float(config.get("enemy_speed", 100.0))
	health = int(config.get("enemy_health", 2))
	contact_damage = int(config.get("contact_damage", 10))
	enemy_type = str(config.get("enemy_type", "hunter"))
	target = target_player
	if enemy_type == "diver":
		body_polygon.color = Color(1.0, 0.82, 0.28, 1.0)
		body_polygon.polygon = PackedVector2Array([
			Vector2(0, -16),
			Vector2(14, -2),
			Vector2(0, 16),
			Vector2(-14, -2)
		])
	else:
		body_polygon.color = Color(1.0, 0.35 + min(float(health) * 0.1, 0.25), 0.3, 1.0)
		body_polygon.polygon = PackedVector2Array([
			Vector2(-14, -12),
			Vector2(14, -12),
			Vector2(10, 12),
			Vector2(-10, 12)
		])


func _physics_process(delta: float) -> void:
	if not alive:
		return

	attack_timer = max(0.0, attack_timer - delta)
	dash_timer = max(0.0, dash_timer - delta)
	dash_cooldown = max(0.0, dash_cooldown - delta)
	if target == null or not target.is_alive():
		velocity = Vector2.ZERO
		move_and_slide()
		return

	if battle != null and battle.is_in_star_danger(global_position):
		take_damage(999)
		return

	var to_player: Vector2 = target.global_position - global_position
	var move_vector := Vector2.ZERO
	if enemy_type == "diver":
		move_vector = _get_diver_velocity(to_player)
	else:
		if to_player.length() > 6.0:
			move_vector = to_player.normalized() * move_speed

	var gravity_vector: Vector2 = battle.get_gravity_vector(global_position) if battle != null else Vector2.ZERO
	velocity = move_vector + gravity_vector
	move_and_slide()

	if global_position.distance_to(target.global_position) < 28.0 and attack_timer <= 0.0:
		attack_timer = attack_cooldown
		target.take_damage(contact_damage)


func _get_diver_velocity(to_player: Vector2) -> Vector2:
	if dash_timer > 0.0:
		return dash_direction * move_speed * 2.1

	if dash_cooldown <= 0.0 and to_player.length() > 24.0:
		dash_direction = to_player.normalized()
		dash_timer = 0.45
		dash_cooldown = 1.8
		return dash_direction * move_speed * 2.1

	if to_player.length() > 6.0:
		return to_player.normalized() * move_speed * 0.65
	return Vector2.ZERO


func take_damage(amount: int) -> void:
	if not alive:
		return
	health -= amount
	if health <= 0:
		alive = false
		defeated.emit(self)
		queue_free()


func freeze() -> void:
	set_physics_process(false)


func unfreeze() -> void:
	if alive:
		set_physics_process(true)
