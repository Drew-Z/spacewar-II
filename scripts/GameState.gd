extends Node

const MENU_SCENE := "res://scenes/MainMenu.tscn"
const BATTLE_SCENE := "res://scenes/BattleScene.tscn"
const RESULT_SCENE := "res://scenes/ResultScene.tscn"

var current_run: Dictionary = {}
var last_run: Dictionary = {}


func begin_run() -> void:
	current_run = {
		"current_wave": 1,
		"survived_waves": 0,
		"kills": 0,
		"selected_upgrades": [],
		"max_health": 100,
		"current_health": 100,
		"move_speed": 260.0,
		"fire_cooldown": 0.22,
		"bullet_damage": 1,
		"bullet_speed": 700.0,
		"missile_ammo": 6,
		"max_missile_ammo": 6,
		"bomb_charges": 2,
		"max_bomb_charges": 2,
		"secondary_index": 0
	}


func get_stat(key: StringName, default_value = null):
	return current_run.get(key, default_value)


func set_stat(key: StringName, value) -> void:
	current_run[key] = value


func add_kill() -> void:
	current_run["kills"] = int(current_run.get("kills", 0)) + 1


func record_wave_cleared(wave_number: int) -> void:
	current_run["survived_waves"] = max(int(current_run.get("survived_waves", 0)), wave_number)
	current_run["current_wave"] = wave_number + 1


func apply_upgrade(upgrade_id: String) -> void:
	match upgrade_id:
		"hull_patch":
			current_run["max_health"] = int(current_run["max_health"]) + 25
			current_run["current_health"] = min(int(current_run["current_health"]) + 25, int(current_run["max_health"]))
		"rapid_loader":
			current_run["fire_cooldown"] = max(0.08, float(current_run["fire_cooldown"]) - 0.03)
		"thrusters":
			current_run["move_speed"] = float(current_run["move_speed"]) + 35.0
		"overcharge":
			current_run["bullet_damage"] = int(current_run["bullet_damage"]) + 1
		"missile_cache":
			current_run["max_missile_ammo"] = int(current_run["max_missile_ammo"]) + 3
			current_run["missile_ammo"] = int(current_run["missile_ammo"]) + 3
		"bomb_supply":
			current_run["max_bomb_charges"] = int(current_run["max_bomb_charges"]) + 1
			current_run["bomb_charges"] = int(current_run["bomb_charges"]) + 1
		_:
			push_warning("Unknown upgrade id: %s" % upgrade_id)


func remember_upgrade(name: String) -> void:
	var picked: Array = current_run.get("selected_upgrades", [])
	picked.append(name)
	current_run["selected_upgrades"] = picked


func finish_run() -> void:
	last_run = current_run.duplicate(true)
