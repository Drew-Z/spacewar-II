extends Node2D

@export var star_count := 80
@export var scroll_speed := 120.0

var stars: Array[Vector2] = []
var field_size := Vector2(960, 540)


func _ready() -> void:
	randomize()
	_reset_stars()


func _reset_stars() -> void:
	stars.clear()
	for _i in range(star_count):
		stars.append(Vector2(randf() * field_size.x, randf() * field_size.y))
	queue_redraw()


func _process(delta: float) -> void:
	for index in range(stars.size()):
		var pos := stars[index]
		pos.y += scroll_speed * delta
		if pos.y > field_size.y:
			pos.y = 0.0
			pos.x = randf() * field_size.x
		stars[index] = pos
	queue_redraw()


func _draw() -> void:
	for pos in stars:
		draw_rect(Rect2(pos, Vector2(2, 2)), Color(0.75, 0.85, 1.0, 0.8))
