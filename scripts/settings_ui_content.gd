extends Control
class_name SettingsUIContent

@onready var instructions_label: Label = $Control/VBoxContainer/CenterContainer/InstructionsLabel

func set_instructions(text: String) -> void:
	instructions_label.text = text
