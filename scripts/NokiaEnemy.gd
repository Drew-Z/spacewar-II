extends CharacterBody2D
class_name NokiaEnemy

signal defeated(enemy)

@onready var body_polygon: Polygon2D = $Body

var move_speed := 140.0
var health := 2
var contact_damage := 12
var enemy_type := "scout"
var fire_timer := 0.0
var fire_cooldown := 1.6
var wave_amplitude := 40.0
var wave_frequency := 3.1
var wave_phase := 0.0
var base_x := 0.0
var battle


func configure(config: Dictionary, battle_controller) -> void:
	battle = battle_controller
	move_speed = float(config.get("speed", 140.0))
	health = int(config.get("health", 2))
	contact_damage = int(config.get("contact_damage", 12))
	enemy_type = str(config.get("enemy_type", "scout"))
	fire_cooldown = float(config.get("fire_cooldown", fire_cooldown))
	wave_amplitude = float(config.get("wave_amplitude", wave_amplitude))
	wave_frequency = float(config.get("wave_frequency", wave_frequency))
	wave_phase = float(config.get("wave_phase", randf() * TAU))
	base_x = global_position.x

	match enemy_type:
		"tank":
			body_polygon.color = Color(1.0, 0.6, 0.3, 1.0)
			body_polygon.polygon = PackedVector2Array([
				Vector2(-14, -12),
				Vector2(14, -12),
				Vector2(16, 10),
				Vector2(-16, 10)
			])
		"diver":
			body_polygon.color = Color(1.0, 0.42, 0.42, 1.0)
			body_polygon.polygon = PackedVector2Array([
				Vector2(0, -16),
				Vector2(16, 12),
				Vector2(0, 6),
				Vector2(-16, 12)
			])
		"sweeper":
			body_polygon.color = Color(0.58, 0.92, 1.0, 1.0)
			body_polygon.polygon = PackedVector2Array([
				Vector2(-18, -8),
				Vector2(18, -8),
				Vector2(8, 12),
				Vector2(-8, 12)
			])
		_:
			body_polygon.color = Color(0.95, 0.85, 0.35, 1.0)
			body_polygon.polygon = PackedVector2Array([
				Vector2(0, -14),
				Vector2(12, 10),
				Vector2(-12, 10)
			])


func _physics_process(delta: float) -> void:
	fire_timer = max(0.0, fire_timer - delta)
	velocity = _movement_velocity()
	move_and_slide()

	if battle != null and fire_timer <= 0.0:
		fire_timer = fire_cooldown
		battle.spawn_enemy_shot(global_position)

	if battle != null:
		var player: Node = battle.player
		if player != null and global_position.distance_to(player.global_position) < 22.0:
			player.take_damage(contact_damage)
			queue_free()

	if global_position.y > battle.get_playfield_rect().end.y + 40.0:
		queue_free()


func take_damage(amount: int) -> void:
	health -= amount
	if health <= 0:
		defeated.emit(self)
		queue_free()


func _movement_velocity() -> Vector2:
	match enemy_type:
		"diver":
			var target_x := base_x
			if battle != null and battle.player != null:
				target_x = battle.player.global_position.x
			var steer := clampf(target_x - global_position.x, -1.0, 1.0) * 150.0
			return Vector2(steer, move_speed * 1.25)
		"sweeper":
			var drift := cos(Time.get_ticks_msec() / 360.0 + wave_phase) * wave_amplitude
			return Vector2(drift, move_speed * 0.72)
		"tank":
			return Vector2(0.0, move_speed * 0.82)
		_:
			var drift := sin(Time.get_ticks_msec() / 1000.0 * wave_frequency + wave_phase) * wave_amplitude
			return Vector2(drift, move_speed)
