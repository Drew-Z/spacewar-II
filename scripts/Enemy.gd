extends CharacterBody2D
class_name Enemy

signal defeated(enemy)

@onready var body_polygon: Polygon2D = $Body

var move_speed := 100.0
var health := 2
var contact_damage := 10
var target
var attack_cooldown := 0.75
var attack_timer := 0.0
var alive := true


func configure(config: Dictionary, target_player) -> void:
	move_speed = float(config.get("enemy_speed", 100.0))
	health = int(config.get("enemy_health", 2))
	contact_damage = int(config.get("contact_damage", 10))
	target = target_player
	body_polygon.color = Color(1.0, 0.35 + min(float(health) * 0.1, 0.25), 0.3, 1.0)


func _physics_process(delta: float) -> void:
	if not alive:
		return

	attack_timer = max(0.0, attack_timer - delta)
	if target == null or not target.is_alive():
		velocity = Vector2.ZERO
		move_and_slide()
		return

	var to_player: Vector2 = target.global_position - global_position
	if to_player.length() > 6.0:
		velocity = to_player.normalized() * move_speed
	else:
		velocity = Vector2.ZERO
	move_and_slide()

	if global_position.distance_to(target.global_position) < 28.0 and attack_timer <= 0.0:
		attack_timer = attack_cooldown
		target.take_damage(contact_damage)


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
