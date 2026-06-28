extends Area2D
class_name NokiaPickup

@onready var body_polygon: Polygon2D = $Body

var pickup_type := "weapon"
var fall_speed := 140.0


func configure(kind: String) -> void:
	pickup_type = kind
	if pickup_type == "bomb":
		body_polygon.color = Color(0.8, 0.6, 1.0, 1.0)
	else:
		body_polygon.color = Color(0.45, 1.0, 0.7, 1.0)


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _process(delta: float) -> void:
	global_position.y += fall_speed * delta
	if global_position.y > 640.0:
		queue_free()


func _on_body_entered(body: Node) -> void:
	if body.has_method("take_damage"):
		if pickup_type == "weapon":
			var level := int(GameState.get_stat("weapon_level", 1))
			GameState.set_stat("weapon_level", min(level + 1, 4))
		else:
			var bombs := int(GameState.get_stat("bombs", 0))
			GameState.set_stat("bombs", min(bombs + 1, 5))
		GameState.set_stat("pickups_collected", int(GameState.get_stat("pickups_collected", 0)) + 1)
		queue_free()
