extends Area2D
class_name Projectile

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var body_polygon: Polygon2D = $Body

var direction := Vector2.UP
var speed := 600.0
var damage := 1
var owner_tag := "player"
var lifetime := 2.0


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func setup(
	spawn_position: Vector2,
	move_direction: Vector2,
	move_speed: float,
	damage_amount: int,
	tint: Color,
	radius: float,
	owner: String
) -> void:
	global_position = spawn_position
	direction = move_direction.normalized()
	speed = move_speed
	damage = damage_amount
	owner_tag = owner
	body_polygon.color = tint
	body_polygon.scale = Vector2.ONE * max(radius / 6.0, 0.8)
	var shape := collision_shape.shape as CircleShape2D
	shape.radius = radius


func _process(delta: float) -> void:
	global_position += direction * speed * delta
	lifetime -= delta
	if lifetime <= 0.0:
		queue_free()


func _on_body_entered(body: Node) -> void:
	if owner_tag == "player" and body.has_method("take_damage"):
		body.take_damage(damage)
		queue_free()
