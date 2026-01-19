extends CanvasLayer
class_name SettingsUI

signal started
signal rotate_camera(degrees: float)

## Reference resolution for scaling (UI designed at this size)
## Lower values = larger UI on screen
@export var reference_width: float = 800.0
@export var reference_height: float = 500.0
@export var min_scale: float = 0.8
@export var max_scale: float = 2.5
@export var rotation_degrees: float = 15.0

@onready var content: SettingsUIContent = $UIContainer/SettingsUIContent
@onready var ui_container: Control = $UIContainer
@onready var rotation_container: Control = $RotationContainer
@onready var left_button: Button = $RotationContainer/HBoxContainer/LeftButton
@onready var right_button: Button = $RotationContainer/HBoxContainer/RightButton

func _ready():
	if content:
		content.started.connect(_on_content_started)
	
	# Connect rotation buttons
	print("SettingsUI _ready - left_button: ", left_button, ", right_button: ", right_button)
	if left_button:
		left_button.pressed.connect(_on_left_pressed)
		print("Connected left button")
	if right_button:
		right_button.pressed.connect(_on_right_pressed)
		print("Connected right button")
	
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
	
	# Apply scale to main UI panel
	ui_container.scale = Vector2(scale_factor, scale_factor)
	
	# Adjust position to keep it in top-right corner after scaling
	var base_margin = 10.0 * scale_factor
	var scaled_width = 240.0 * scale_factor
	ui_container.position = Vector2(viewport_size.x - scaled_width - base_margin, base_margin)
	
	# Scale and position rotation buttons at bottom center
	if rotation_container:
		rotation_container.scale = Vector2(scale_factor, scale_factor)
		var button_width = 120.0 * scale_factor  # Approximate width of both buttons
		rotation_container.position = Vector2(
			(viewport_size.x - button_width) / 2.0,
			viewport_size.y - 70.0 * scale_factor
		)

func _on_content_started():
	started.emit()

func _on_left_pressed():
	print("Left button pressed! Emitting rotate_camera(", rotation_degrees, ")")
	rotate_camera.emit(rotation_degrees)

func _on_right_pressed():
	print("Right button pressed! Emitting rotate_camera(", -rotation_degrees, ")")
	rotate_camera.emit(-rotation_degrees)

func set_instructions(text: String) -> void:
	if content:
		content.set_instructions(text)
