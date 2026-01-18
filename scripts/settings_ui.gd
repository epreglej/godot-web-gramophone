extends CanvasLayer
class_name SettingsUI

signal started

@onready var content: SettingsUIContent = $UIContainer/SettingsUIContent

func _ready():
	if content:
		content.started.connect(_on_content_started)

func _on_content_started():
	started.emit()

func set_instructions(text: String) -> void:
	if content:
		content.set_instructions(text)
