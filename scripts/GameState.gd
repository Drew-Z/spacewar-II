extends Node

const MENU_SCENE := "res://scenes/NokiaMenu.tscn"
const BATTLE_SCENE := "res://scenes/NokiaBattle.tscn"
const RESULT_SCENE := "res://scenes/NokiaResult.tscn"

var current_run: Dictionary = {}
var last_run: Dictionary = {}


func begin_run() -> void:
	current_run = {
		"current_stage": 1,
		"total_stages": 3,
		"score": 0,
		"lives": 3,
		"max_health": 100,
		"current_health": 100,
		"weapon_level": 1,
		"bombs": 2,
		"pickups_collected": 0,
		"enemies_destroyed": 0,
		"best_chain": 0,
		"chain_bonus_score": 0,
		"stage_clear_bonus": 0,
		"distance": 0.0,
		"selected_upgrades": [],
		"ship_name": "Falcon",
		"move_speed": 260.0,
		"fire_cooldown": 0.18,
		"bullet_damage": 1,
		"bullet_speed": 760.0
	}


func get_stat(key: StringName, default_value = null):
	return current_run.get(key, default_value)


func set_stat(key: StringName, value) -> void:
	current_run[key] = value


func add_kill() -> void:
	current_run["enemies_destroyed"] = int(current_run.get("enemies_destroyed", 0)) + 1
	current_run["score"] = int(current_run.get("score", 0)) + 100


func record_wave_cleared(wave_number: int) -> void:
	current_run["current_stage"] = max(int(current_run.get("current_stage", 1)), wave_number + 1)


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
		"hyperfield_tuning":
			current_run["max_hyperspace_charges"] = int(current_run["max_hyperspace_charges"]) + 1
			current_run["hyperspace_charges"] = int(current_run["hyperspace_charges"]) + 1
			current_run["hyperspace_stability"] = min(float(current_run["hyperspace_stability"]) + 0.08, 0.24)
		"solar_shield":
			current_run["star_resistance"] = min(float(current_run["star_resistance"]) + 0.35, 0.7)
		_:
			push_warning("Unknown upgrade id: %s" % upgrade_id)


func remember_upgrade(name: String) -> void:
	var picked: Array = current_run.get("selected_upgrades", [])
	picked.append(name)
	current_run["selected_upgrades"] = picked


func finish_run() -> void:
	last_run = current_run.duplicate(true)
