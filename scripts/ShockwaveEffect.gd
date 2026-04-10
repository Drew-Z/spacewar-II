extends Node2D

var elapsed := 0.0
var duration := 0.22
var max_radius := 150.0


func configure(radius: float) -> void:
	max_radius = radius


func _process(delta: float) -> void:
	elapsed += delta
	queue_redraw()
	if elapsed >= duration:
		queue_free()


func _draw() -> void:
	var t := clampf(elapsed / duration, 0.0, 1.0)
	var radius := lerpf(24.0, max_radius, t)
	draw_arc(Vector2.ZERO, radius, 0.0, TAU, 48, Color(0.6, 0.95, 1.0, 1.0 - t), 4.0)
