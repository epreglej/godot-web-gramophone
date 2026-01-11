extends Control
class_name SettingsUIContent

@onready var instructions_label: Label = $Control/VBoxContainer/CenterContainer/InstructionsLabel
@onready var start_label: RichTextLabel = $Control/VBoxContainer/CenterContainer/StartLabel
@onready var start_button: Button = $Control/VBoxContainer/StartButton
@onready var restart_button: Button = $Control/VBoxContainer/RestartButton


func _ready() -> void:
	start_button.pressed.connect(_on_start_pressed)
	restart_button.pressed.connect(_on_restart_pressed)


func set_instructions(text: String) -> void:
	instructions_label.text = text


func _on_start_pressed() -> void:
	start_label.set_visible(false)
	start_button.set_visible(false)
	instructions_label.set_visible(true)
	restart_button.set_visible(true)


func _on_restart_pressed() -> void:
	get_tree().reload_current_scene()
