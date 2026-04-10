extends Control


func start_game() -> void:
	get_tree().change_scene_to_file(GameState.BATTLE_SCENE)


func _on_start_button_pressed() -> void:
	start_game()


func _on_exit_button_pressed() -> void:
	get_tree().quit()
