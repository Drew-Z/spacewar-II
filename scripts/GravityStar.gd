extends Node2D

@export var gravity_strength := 160000.0
@export var danger_radius := 34.0
@export var safe_spawn_radius := 110.0
@export var contact_damage := 14


func _ready() -> void:
	queue_redraw()


func _draw() -> void:
	draw_circle(Vector2.ZERO, safe_spawn_radius, Color(0.95, 0.6, 0.16, 0.08))
	draw_circle(Vector2.ZERO, 48.0, Color(0.95, 0.74, 0.22, 0.12))
	draw_circle(Vector2.ZERO, 28.0, Color(1.0, 0.75, 0.18, 0.85))
	draw_circle(Vector2.ZERO, 14.0, Color(1.0, 0.95, 0.55, 0.95))
