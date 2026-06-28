extends CanvasLayer

@onready var health_value: Label = %HealthValue
@onready var wave_value: Label = %WaveValue
@onready var primary_value: Label = %PrimaryValue
@onready var secondary_value: Label = %SecondaryValue
@onready var systems_value: Label = %SystemsValue
@onready var center_message: Label = %CenterMessage
@onready var message_timer: Timer = %MessageTimer
@onready var top_bar: PanelContainer = $Root/TopBar
@onready var hint_label: Label = $Root/HintLabel


func _ready() -> void:
	_apply_showcase_style()


func set_health(current_health: int, max_health: int) -> void:
	health_value.text = "HP %d/%d" % [current_health, max_health]
	var ratio := 1.0
	if max_health > 0:
		ratio = float(current_health) / float(max_health)
	var health_color := Color(0.74, 1.0, 0.82) if ratio > 0.35 else Color(1.0, 0.46, 0.42)
	health_value.add_theme_color_override("font_color", health_color)


func set_wave(wave_number: int, active_enemies: int, queued_enemies: int) -> void:
	wave_value.text = "WAVE %d  LIVE %d  Q %d" % [wave_number, active_enemies, queued_enemies]


func set_primary_status(text: String) -> void:
	primary_value.text = "PRI " + text


func set_secondary_status(text: String) -> void:
	secondary_value.text = "SEC " + text


func set_systems_status(text: String) -> void:
	systems_value.text = "SYS " + text


func show_message(text: String) -> void:
	center_message.text = text
	center_message.visible = true
	message_timer.start()


func _on_message_timer_timeout() -> void:
	center_message.visible = false


func _apply_showcase_style() -> void:
	top_bar.add_theme_stylebox_override(
		"panel",
		_box_style(Color(0.022, 0.032, 0.062, 0.88), Color(0.50, 0.62, 1.0, 0.70), 1)
	)
	top_bar.get_node("MarginContainer/HBoxContainer").add_theme_constant_override("separation", 12)

	var labels: Array[Label] = [health_value, wave_value, primary_value, secondary_value, systems_value]
	for label in labels:
		label.add_theme_font_size_override("font_size", 14)
		label.add_theme_color_override("font_color", Color(0.86, 0.93, 1.0))

	hint_label.text = "SPACE fire  Q swap  E secondary  F hyperspace"
	hint_label.add_theme_font_size_override("font_size", 13)
	hint_label.add_theme_color_override("font_color", Color(0.68, 0.78, 0.94))

	center_message.add_theme_font_size_override("font_size", 26)
	center_message.add_theme_color_override("font_color", Color(1.0, 0.94, 0.72))


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
	style.shadow_size = 10
	style.shadow_color = Color(0.0, 0.0, 0.0, 0.34)
	return style
