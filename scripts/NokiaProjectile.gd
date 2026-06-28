extends Area2D
class_name NokiaProjectile

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var body_polygon: Polygon2D = $Body

var velocity := Vector2.ZERO
var damage := 1
var owner_tag := "player"
var lifetime := 2.0


func setup(spawn_position: Vector2, move_velocity: Vector2, damage_amount: int, tint: Color) -> void:
	global_position = spawn_position
	velocity = move_velocity
	damage = damage_amount
	body_polygon.color = tint


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _process(delta: float) -> void:
	global_position += velocity * delta
	lifetime -= delta
	if lifetime <= 0.0:
		queue_free()


func _on_body_entered(body: Node) -> void:
	if owner_tag == "player" and body.has_method("take_damage"):
		body.take_damage(damage)
		queue_free()
	elif owner_tag == "enemy" and body.has_method("take_damage"):
		body.take_damage(damage)
		queue_free()
