extends RefCounted
class_name WaveDirector


func build_wave(wave_number: int) -> Dictionary:
	return {
		"wave": wave_number,
		"enemy_count": 3 + wave_number * 2,
		"enemy_health": 2 + int((wave_number - 1) / 2),
		"enemy_speed": 85.0 + float(wave_number) * 14.0,
		"contact_damage": 10 + wave_number * 2,
		"spawn_interval": max(0.22, 0.72 - float(wave_number) * 0.05)
	}
