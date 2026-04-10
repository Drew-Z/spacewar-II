extends CanvasLayer

@onready var health_value: Label = %HealthValue
@onready var wave_value: Label = %WaveValue
@onready var primary_value: Label = %PrimaryValue
@onready var secondary_value: Label = %SecondaryValue
@onready var center_message: Label = %CenterMessage
@onready var message_timer: Timer = %MessageTimer


func set_health(current_health: int, max_health: int) -> void:
	health_value.text = "%d / %d" % [current_health, max_health]


func set_wave(wave_number: int, active_enemies: int, queued_enemies: int) -> void:
	wave_value.text = "第 %d 波  敌人 %d  待刷 %d" % [wave_number, active_enemies, queued_enemies]


func set_primary_status(text: String) -> void:
	primary_value.text = text


func set_secondary_status(text: String) -> void:
	secondary_value.text = text


func show_message(text: String) -> void:
	center_message.text = text
	center_message.visible = true
	message_timer.start()


func _on_message_timer_timeout() -> void:
	center_message.visible = false
