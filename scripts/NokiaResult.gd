extends Control

@onready var result_value: Label = %ResultValue
@onready var score_value: Label = %ScoreValue
@onready var stage_value: Label = %StageValue
@onready var enemies_value: Label = %EnemiesValue
@onready var pickups_value: Label = %PickupsValue
@onready var distance_value: Label = %DistanceValue
@onready var background: ColorRect = $Background
@onready var panel: PanelContainer = $Panel
@onready var vbox: VBoxContainer = $Panel/MarginContainer/VBoxContainer
@onready var score_label: Label = $Panel/MarginContainer/VBoxContainer/ScoreLabel
@onready var stage_label: Label = $Panel/MarginContainer/VBoxContainer/StageLabel
@onready var enemies_label: Label = $Panel/MarginContainer/VBoxContainer/EnemiesLabel
@onready var pickups_label: Label = $Panel/MarginContainer/VBoxContainer/PickupsLabel
@onready var distance_label: Label = $Panel/MarginContainer/VBoxContainer/DistanceLabel
@onready var retry_button: Button = $Panel/MarginContainer/VBoxContainer/Buttons/RetryButton
@onready var menu_button: Button = $Panel/MarginContainer/VBoxContainer/Buttons/MenuButton


func _ready() -> void:
	_apply_showcase_style()
	var run: Dictionary = GameState.last_run
	var victory := bool(run.get("result_victory", false))
	result_value.text = "ROUTE CLEARED" if victory else "RUN ENDED"
	result_value.add_theme_color_override(
		"font_color",
		Color(0.50, 1.0, 0.74) if victory else Color(1.0, 0.56, 0.52)
	)
	score_value.text = "%06d" % int(run.get("score", 0))
	var stage := int(run.get("current_stage", 1))
	var total := int(run.get("total_stages", 1))
	stage_value.text = "Route %d of %d" % [stage, total]
	enemies_value.text = "%d targets" % int(run.get("enemies_destroyed", 0))
	pickups_value.text = "%d upgrades   clear +%d" % [
		int(run.get("pickups_collected", 0)),
		int(run.get("stage_clear_bonus", 0)),
	]
	distance_value.text = "%d m   chain x%d   bonus +%d" % [
		int(run.get("distance", 0.0)),
		int(run.get("best_chain", 0)),
		int(run.get("chain_bonus_score", 0)),
	]
	_layout_panel()


func _on_retry_button_pressed() -> void:
	get_tree().change_scene_to_file(GameState.BATTLE_SCENE)


func _on_menu_button_pressed() -> void:
	get_tree().change_scene_to_file(GameState.MENU_SCENE)


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED and is_node_ready():
		_layout_panel()


func _apply_showcase_style() -> void:
	background.color = Color(0.018, 0.026, 0.052, 1.0)
	panel.add_theme_stylebox_override(
		"panel",
		_box_style(Color(0.045, 0.058, 0.105, 0.96), Color(0.48, 0.62, 1.0, 0.78), 2)
	)
	vbox.add_theme_constant_override("separation", 9)

	score_label.text = "SCORE REGISTER"
	stage_label.text = "ROUTE STATUS"
	enemies_label.text = "TARGETS CLEARED"
	pickups_label.text = "UPGRADES"
	distance_label.text = "DISTANCE / CHAIN"

	var stat_labels: Array[Label] = [score_label, stage_label, enemies_label, pickups_label, distance_label]
	for label in stat_labels:
		label.add_theme_font_size_override("font_size", 12)
		label.add_theme_color_override("font_color", Color(0.63, 0.73, 0.90))

	for value in [score_value, stage_value, enemies_value, pickups_value, distance_value]:
		value.add_theme_font_size_override("font_size", 18)
		value.add_theme_color_override("font_color", Color(0.94, 0.98, 1.0))
		value.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	result_value.add_theme_font_size_override("font_size", 30)
	result_value.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	retry_button.text = "Retry Route"
	menu_button.text = "Back to Menu"
	retry_button.custom_minimum_size = Vector2(142.0, 40.0)
	menu_button.custom_minimum_size = Vector2(142.0, 40.0)
	_apply_button_style(retry_button, Color(0.46, 0.70, 1.0), true)
	_apply_button_style(menu_button, Color(0.58, 0.66, 0.82), false)


func _layout_panel() -> void:
	var viewport_size: Vector2 = get_viewport_rect().size
	var panel_width: float = min(540.0, max(320.0, viewport_size.x - 32.0))
	var panel_height: float = min(450.0, max(386.0, viewport_size.y - 48.0))
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.offset_left = -panel_width * 0.5
	panel.offset_right = panel_width * 0.5
	panel.offset_top = -panel_height * 0.5
	panel.offset_bottom = panel_height * 0.5


func _apply_button_style(button: Button, accent: Color, primary: bool) -> void:
	var fill := Color(0.08, 0.10, 0.16, 1.0).lerp(accent, 0.24 if primary else 0.10)
	button.add_theme_stylebox_override("normal", _box_style(fill, accent, 1))
	button.add_theme_stylebox_override("hover", _box_style(fill.lerp(accent, 0.20), accent, 1))
	button.add_theme_stylebox_override("pressed", _box_style(Color(0.035, 0.045, 0.075, 1.0).lerp(accent, 0.24), accent, 1))
	button.add_theme_stylebox_override("focus", _box_style(fill.lerp(accent, 0.30), accent, 2))
	button.add_theme_color_override("font_color", Color(0.96, 0.98, 1.0))
	button.add_theme_color_override("font_hover_color", Color(1.0, 1.0, 1.0))
	button.add_theme_color_override("font_pressed_color", Color(0.04, 0.05, 0.08))
	button.add_theme_font_size_override("font_size", 15 if primary else 14)


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
	style.content_margin_left = 12.0
	style.content_margin_top = 8.0
	style.content_margin_right = 12.0
	style.content_margin_bottom = 8.0
	style.shadow_size = 14
	style.shadow_color = Color(0.0, 0.0, 0.0, 0.36)
	return style
