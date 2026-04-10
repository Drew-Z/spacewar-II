extends CanvasLayer

signal upgrade_selected(upgrade_data: Dictionary)

@onready var choice_buttons: Array[Button] = [
	%Choice1,
	%Choice2,
	%Choice3
]

var offered_choices: Array[Dictionary] = []


func _ready() -> void:
	hide()


func present_choices(choices: Array[Dictionary]) -> void:
	offered_choices = choices
	for index in range(choice_buttons.size()):
		var button := choice_buttons[index]
		if index < offered_choices.size():
			var upgrade: Dictionary = offered_choices[index]
			button.text = "%d. %s\n%s" % [index + 1, upgrade["name"], upgrade["description"]]
			button.disabled = false
		else:
			button.text = ""
			button.disabled = true
	show()


func debug_pick_first() -> void:
	if offered_choices.is_empty():
		return
	_emit_pick(0)


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event is InputEventKey and event.pressed and not event.echo:
		match event.physical_keycode:
			KEY_1:
				_emit_pick(0)
			KEY_2:
				_emit_pick(1)
			KEY_3:
				_emit_pick(2)


func _emit_pick(index: int) -> void:
	if index < 0 or index >= offered_choices.size():
		return
	upgrade_selected.emit(offered_choices[index])


func _on_choice_1_pressed() -> void:
	_emit_pick(0)


func _on_choice_2_pressed() -> void:
	_emit_pick(1)


func _on_choice_3_pressed() -> void:
	_emit_pick(2)
