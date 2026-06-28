extends RefCounted
class_name WaveDirector


func build_wave(wave_number: int) -> Dictionary:
	var spawn_queue: Array[Dictionary] = []
	var enemy_count := 3 + wave_number * 2
	for index in range(enemy_count):
		spawn_queue.append(_build_enemy_entry(wave_number, index))

	return {
		"wave": wave_number,
		"enemy_count": enemy_count,
		"enemy_health": 2 + int((wave_number - 1) / 2),
		"enemy_speed": 85.0 + float(wave_number) * 14.0,
		"contact_damage": 10 + wave_number * 2,
		"spawn_interval": max(0.22, 0.72 - float(wave_number) * 0.05),
		"spawn_queue": spawn_queue
	}


func _build_enemy_entry(wave_number: int, index: int) -> Dictionary:
	var enemy_type := "hunter"
	if wave_number >= 2 and (index + wave_number) % 4 == 0:
		enemy_type = "diver"
	if wave_number >= 4 and index % 3 == 0:
		enemy_type = "diver"

	return {
		"enemy_type": enemy_type
	}
