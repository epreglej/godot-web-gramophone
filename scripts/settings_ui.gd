extends CanvasLayer
class_name SettingsUI

signal started

## Reference resolution for scaling (UI designed at this size)
## Lower values = larger UI on screen
@export var reference_width: float = 1280.0
@export var reference_height: float = 720.0
@export var min_scale: float = 0.6
@export var max_scale: float = 2.0

@onready var content: SettingsUIContent = $UIContainer/SettingsUIContent
@onready var ui_container: Control = $UIContainer

func _ready():
	if content:
		content.started.connect(_on_content_started)
	
	# Initial scale
	_update_ui_scale()
	
	# Update scale when window resizes
	get_tree().root.size_changed.connect(_update_ui_scale)

func _update_ui_scale():
	if not ui_container:
		return
	
	var viewport_size = get_viewport().get_visible_rect().size
	
	# Calculate scale based on smaller dimension to ensure it fits
	var scale_x = viewport_size.x / reference_width
	var scale_y = viewport_size.y / reference_height
	var scale_factor = min(scale_x, scale_y)
	
	# Clamp to reasonable range
	scale_factor = clamp(scale_factor, min_scale, max_scale)
	
	# Apply scale
	ui_container.scale = Vector2(scale_factor, scale_factor)
	
	# Adjust position to keep it in top-right corner after scaling
	var base_margin = 10.0 * scale_factor
	var scaled_width = 240.0 * scale_factor
	ui_container.position = Vector2(viewport_size.x - scaled_width - base_margin, base_margin)

func _on_content_started():
	started.emit()

func set_instructions(text: String) -> void:
	if content:
		content.set_instructions(text)
