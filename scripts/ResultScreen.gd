extends Control

@onready var survived_value: Label = %SurvivedValue
@onready var kills_value: Label = %KillsValue
@onready var upgrades_value: Label = %UpgradesValue


func _ready() -> void:
	var run: Dictionary = GameState.last_run
	survived_value.text = str(run.get("survived_waves", 0))
	kills_value.text = str(run.get("kills", 0))

	var upgrades: Array = run.get("selected_upgrades", [])
	if upgrades.is_empty():
		upgrades_value.text = "No upgrades selected."
	else:
		upgrades_value.text = "\n".join(upgrades)


func _on_retry_button_pressed() -> void:
	get_tree().change_scene_to_file(GameState.BATTLE_SCENE)


func _on_menu_button_pressed() -> void:
	get_tree().change_scene_to_file(GameState.MENU_SCENE)
