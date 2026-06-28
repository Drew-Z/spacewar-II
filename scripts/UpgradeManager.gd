extends RefCounted
class_name UpgradeManager

const UPGRADE_POOL := [
	{
		"id": "hull_patch",
		"name": "Hull Patch",
		"description": "Max HP +25 and heal 25 immediately."
	},
	{
		"id": "rapid_loader",
		"name": "Rapid Loader",
		"description": "Reduce primary cooldown for steadier DPS."
	},
	{
		"id": "thrusters",
		"name": "Thrusters",
		"description": "Move faster and kite enemy packs more safely."
	},
	{
		"id": "overcharge",
		"name": "Overcharge",
		"description": "Primary weapon damage +1."
	},
	{
		"id": "missile_cache",
		"name": "Missile Cache",
		"description": "Max missiles +3 and refill 3 missiles."
	},
	{
		"id": "bomb_supply",
		"name": "Shockwave Supply",
		"description": "Max shockwaves +1 and refill 1 charge."
	},
	{
		"id": "hyperfield_tuning",
		"name": "Hyperfield Tuning",
		"description": "Max hyperspace +1, refill 1 charge, reduce jump failure risk."
	},
	{
		"id": "solar_shield",
		"name": "Solar Shield",
		"description": "Reduce damage taken from the heavy star."
	}
]


func get_choices() -> Array[Dictionary]:
	var pool: Array = UPGRADE_POOL.duplicate(true)
	pool.shuffle()
	var picks: Array[Dictionary] = []
	for item in pool:
		picks.append(item)
		if picks.size() == 3:
			break
	return picks
