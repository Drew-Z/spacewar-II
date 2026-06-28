extends Control


func _ready() -> void:
	_apply_showcase_style()
	$StartButton.grab_focus()


func start_game() -> void:
	get_tree().change_scene_to_file(GameState.BATTLE_SCENE)


func _on_start_button_pressed() -> void:
	start_game()


func _on_exit_button_pressed() -> void:
	get_tree().quit()


func _apply_showcase_style() -> void:
	$Background.color = Color(0.025, 0.035, 0.07, 1.0)

	var card := PanelContainer.new()
	card.name = "ShowcaseCard"
	card.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.set_anchors_preset(Control.PRESET_CENTER)
	card.offset_left = -260.0
	card.offset_top = -184.0
	card.offset_right = 260.0
	card.offset_bottom = 196.0
	card.add_theme_stylebox_override("panel", _box_style(Color(0.055, 0.07, 0.12, 0.95), Color(0.46, 0.52, 1.0, 0.78), 2))
	add_child(card)
	move_child(card, 1)

	var glow := ColorRect.new()
	glow.name = "SignalBand"
	glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	glow.color = Color(0.18, 0.24, 0.52, 0.26)
	glow.set_anchors_preset(Control.PRESET_CENTER)
	glow.offset_left = -360.0
	glow.offset_top = -120.0
	glow.offset_right = 360.0
	glow.offset_bottom = 120.0
	add_child(glow)
	move_child(glow, 1)

	$Title.text = "SPACE WAR II"
	$Title.offset_top = -78.0
	$Title.offset_bottom = -24.0
	$Title.add_theme_font_size_override("font_size", 38)
	$Title.add_theme_color_override("font_color", Color(0.96, 0.98, 1.0))

	$Subtitle.text = "Mobile Vertical Shooter Showcase"
	$Subtitle.offset_top = -18.0
	$Subtitle.offset_bottom = 18.0
	$Subtitle.add_theme_font_size_override("font_size", 16)
	$Subtitle.add_theme_color_override("font_color", Color(1.0, 0.82, 0.45))

	$Controls.text = "Survive waves, collect upgrades, clear the boss route.\nMove: WASD / Arrows    Fire: Space    Bomb: X"
	$Controls.offset_top = 26.0
	$Controls.offset_bottom = 98.0
	$Controls.add_theme_font_size_override("font_size", 16)
	$Controls.add_theme_color_override("font_color", Color(0.76, 0.84, 0.95))

	$StartButton.text = "Start Showcase"
	$StartButton.offset_left = -136.0
	$StartButton.offset_top = -22.0
	$StartButton.offset_right = 136.0
	$StartButton.offset_bottom = 22.0
	_apply_button_style($StartButton, Color(0.42, 0.68, 1.0), true)

	$ExitButton.text = "Exit"
	$ExitButton.offset_left = -136.0
	$ExitButton.offset_top = -20.0
	$ExitButton.offset_right = 136.0
	$ExitButton.offset_bottom = 20.0
	_apply_button_style($ExitButton, Color(0.50, 0.58, 0.72), false)


func _apply_button_style(button: Button, accent: Color, primary: bool) -> void:
	var fill := Color(0.08, 0.10, 0.16, 1.0).lerp(accent, 0.24 if primary else 0.10)
	button.add_theme_stylebox_override("normal", _box_style(fill, accent, 1))
	button.add_theme_stylebox_override("hover", _box_style(fill.lerp(accent, 0.20), accent, 1))
	button.add_theme_stylebox_override("pressed", _box_style(Color(0.04, 0.05, 0.08, 1.0).lerp(accent, 0.22), accent, 1))
	button.add_theme_stylebox_override("focus", _box_style(fill.lerp(accent, 0.30), accent, 2))
	button.add_theme_color_override("font_color", Color(0.96, 0.98, 1.0))
	button.add_theme_color_override("font_hover_color", Color(1.0, 1.0, 1.0))
	button.add_theme_color_override("font_pressed_color", Color(0.04, 0.05, 0.08))
	button.add_theme_font_size_override("font_size", 18 if primary else 16)


func _box_style(fill: Color, border: Color, border_width: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.border_width_left = border_width
	style.border_width_top = border_width
	style.border_width_right = border_width
	style.border_width_bottom = border_width
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	style.content_margin_left = 14.0
	style.content_margin_top = 10.0
	style.content_margin_right = 14.0
	style.content_margin_bottom = 10.0
	return style
