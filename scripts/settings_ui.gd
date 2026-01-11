extends Node3D
class_name SettingsUI

signal content_ready
signal started

@onready var _viewport_2d_in_3d: XRToolsViewport2DIn3D = $Screen/Viewport2Din3D

var _content: SettingsUIContent = null

func _ready():
	_bind_content()

func _bind_content() -> void:
	var scene := _viewport_2d_in_3d.get_scene_instance()
	if scene:
		_content = scene as SettingsUIContent
		_content.started.connect(_on_started)
		content_ready.emit()
	else:
		await get_tree().process_frame
		_bind_content()

func set_instructions(text: String) -> void:
	_content.set_instructions(text)


func _on_started() -> void:
	started.emit()
