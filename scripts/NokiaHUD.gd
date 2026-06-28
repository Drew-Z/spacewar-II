extends CanvasLayer

@onready var score_value: Label = %ScoreValue
@onready var lives_value: Label = %LivesValue
@onready var health_value: Label = %HealthValue
@onready var weapon_value: Label = %WeaponValue
@onready var bombs_value: Label = %BombsValue
@onready var stage_value: Label = %StageValue
@onready var top_bar: PanelContainer = $Root/TopBar
@onready var stat_box: HBoxContainer = $Root/TopBar/MarginContainer/HBoxContainer
@onready var score_label: Label = $Root/TopBar/MarginContainer/HBoxContainer/ScoreLabel
@onready var lives_label: Label = $Root/TopBar/MarginContainer/HBoxContainer/LivesLabel
@onready var health_label: Label = $Root/TopBar/MarginContainer/HBoxContainer/HealthLabel
@onready var weapon_label: Label = $Root/TopBar/MarginContainer/HBoxContainer/WeaponLabel
@onready var bombs_label: Label = $Root/TopBar/MarginContainer/HBoxContainer/BombsLabel

var chain_label: Label
var chain_value: Label


func _ready() -> void:
	_install_chain_meter()
	_apply_showcase_style()


func set_score(score: int) -> void:
	score_value.text = "%06d" % score


func set_lives(lives: int) -> void:
	lives_value.text = "x%d" % lives


func set_health(current_health: int, max_health: int) -> void:
	health_value.text = "%d / %d" % [current_health, max_health]
	var ratio := 1.0
	if max_health > 0:
		ratio = float(current_health) / float(max_health)
	var health_color := Color(1.0, 0.94, 0.74) if ratio > 0.35 else Color(1.0, 0.44, 0.42)
	health_value.add_theme_color_override("font_color", health_color)


func set_weapon_level(level: int) -> void:
	weapon_value.text = "Lv%d" % level


func set_bombs(bombs: int) -> void:
	bombs_value.text = "x%d" % bombs


func set_stage(stage: int, distance: float, stage_length: float, total_stages: int) -> void:
	var progress := 0.0
	if stage_length > 0.0:
		progress = clampf(distance / stage_length, 0.0, 1.0)
	stage_value.text = "ST %d/%d  %d%%" % [stage, total_stages, int(progress * 100.0)]


func set_chain(chain_count: int, best_chain: int, chain_bonus_score: int) -> void:
	if chain_value == null:
		return
	if chain_count >= 2:
		chain_value.text = "x%d" % chain_count
		chain_value.add_theme_color_override("font_color", Color(1.0, 0.78, 0.42))
	else:
		chain_value.text = "B%d" % best_chain
		chain_value.add_theme_color_override("font_color", Color(0.80, 0.88, 1.0))
	chain_value.tooltip_text = "Best chain %d / bonus %d" % [best_chain, chain_bonus_score]


func _install_chain_meter() -> void:
	chain_label = Label.new()
	chain_label.name = "ChainLabel"
	chain_label.text = "CHAIN"
	stat_box.add_child(chain_label)

	chain_value = Label.new()
	chain_value.name = "ChainValue"
	chain_value.text = "B0"
	chain_value.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	chain_value.custom_minimum_size.x = 36.0
	stat_box.add_child(chain_value)


func _apply_showcase_style() -> void:
	top_bar.add_theme_stylebox_override(
		"panel",
		_box_style(Color(0.025, 0.035, 0.07, 0.88), Color(0.50, 0.62, 1.0, 0.70), 1)
	)
	stat_box.add_theme_constant_override("separation", 8)

	score_label.text = "SCORE"
	lives_label.text = "LIFE"
	health_label.text = "HP"
	weapon_label.text = "WPN"
	bombs_label.text = "BOMB"

	var labels: Array[Label] = [
		score_label,
		lives_label,
		health_label,
		weapon_label,
		bombs_label,
		chain_label,
		score_value,
		lives_value,
		health_value,
		weapon_value,
		bombs_value,
		chain_value,
		stage_value,
	]
	for label in labels:
		label.add_theme_font_size_override("font_size", 12)
		label.add_theme_color_override("font_color", Color(0.80, 0.88, 1.0))

	for value in [score_value, lives_value, health_value, weapon_value, bombs_value, stage_value]:
		value.add_theme_color_override("font_color", Color(1.0, 0.94, 0.74))

	stage_value.add_theme_color_override("font_color", Color(0.58, 0.84, 1.0))


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
	style.content_margin_left = 10.0
	style.content_margin_top = 6.0
	style.content_margin_right = 10.0
	style.content_margin_bottom = 6.0
	style.shadow_size = 10
	style.shadow_color = Color(0.0, 0.0, 0.0, 0.34)
	return style
