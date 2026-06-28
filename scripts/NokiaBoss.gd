extends CharacterBody2D
class_name NokiaBoss

signal defeated

@onready var body_polygon: Polygon2D = $Body

var health := 60
var move_speed := 90.0
var fire_timer := 0.0
var fire_cooldown := 0.8
var battle
var direction := 1.0
var boss_stage := 1


func configure(battle_controller, config: Dictionary = {}) -> void:
	battle = battle_controller
	boss_stage = int(config.get("stage", boss_stage))
	health = int(config.get("health", 54 + boss_stage * 18))
	move_speed = float(config.get("move_speed", 74.0 + float(boss_stage) * 12.0))
	fire_cooldown = float(config.get("fire_cooldown", max(0.46, 0.86 - float(boss_stage) * 0.10)))
	body_polygon.color = Color(0.9, 0.4, 0.3, 1.0)


func _physics_process(delta: float) -> void:
	fire_timer = max(0.0, fire_timer - delta)
	velocity = Vector2(direction * move_speed, 0.0)
	move_and_slide()

	if battle != null:
		var rect: Rect2 = battle.get_playfield_rect()
		if global_position.x < rect.position.x + 60.0:
			direction = 1.0
		if global_position.x > rect.end.x - 60.0:
			direction = -1.0

		if fire_timer <= 0.0:
			fire_timer = fire_cooldown
			battle.spawn_boss_shot(global_position)


func take_damage(amount: int) -> void:
	health -= amount
	if health <= 0:
		defeated.emit()
		queue_free()
