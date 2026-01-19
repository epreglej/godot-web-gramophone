extends CanvasLayer
class_name SettingsUI

signal started
signal rotate_camera(degrees: float)
signal vinyl_flip
signal vinyl_select
signal vinyl_cancel

@export var rotation_degrees: float = 15.0

@onready var content: SettingsUIContent = $SettingsUIContent
@onready var rotation_container: Control = $RotationContainer
@onready var left_button: Button = $RotationContainer/HBoxContainer/LeftButton
@onready var right_button: Button = $RotationContainer/HBoxContainer/RightButton
@onready var vinyl_container: Control = $VinylContainer
@onready var vinyl_info_label: RichTextLabel = $VinylContainer/PanelContainer/MarginContainer/VBoxContainer/VinylInfoLabel
@onready var flip_button: Button = $VinylContainer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/FlipButton
@onready var select_button: Button = $VinylContainer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/SelectButton
@onready var cancel_button: Button = $VinylContainer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/CancelButton

func _ready():
	if content:
		content.started.connect(_on_content_started)
	
	# Connect rotation buttons
	if left_button:
		left_button.pressed.connect(_on_left_pressed)
	if right_button:
		right_button.pressed.connect(_on_right_pressed)
	
	# Connect vinyl buttons
	if flip_button:
		flip_button.pressed.connect(_on_flip_pressed)
	if select_button:
		select_button.pressed.connect(_on_select_pressed)
	if cancel_button:
		cancel_button.pressed.connect(_on_cancel_pressed)
	
	# Hide vinyl container and rotation arrows by default
	if vinyl_container:
		vinyl_container.visible = false
	if rotation_container:
		rotation_container.visible = false
	
	# Initial positioning
	_update_ui_positions()
	
	# Update when window resizes
	get_tree().root.size_changed.connect(_update_ui_positions)

func _update_ui_positions():
	var viewport_size = get_viewport().get_visible_rect().size
	
	# Position rotation buttons at bottom center
	if rotation_container:
		var button_width = 130.0
		rotation_container.position = Vector2(
			(viewport_size.x - button_width) / 2.0,
			viewport_size.y - 75.0
		)
	
	# Position vinyl container at bottom center (above rotation buttons)
	if vinyl_container:
		var vinyl_width = 260.0
		vinyl_container.position = Vector2(
			(viewport_size.x - vinyl_width) / 2.0,
			viewport_size.y - 220.0
		)

func _on_content_started():
	# Show rotation arrows when game starts
	if rotation_container:
		rotation_container.visible = true
	started.emit()

func _on_left_pressed():
	rotate_camera.emit(rotation_degrees)

func _on_right_pressed():
	rotate_camera.emit(-rotation_degrees)

func _on_flip_pressed():
	vinyl_flip.emit()

func _on_select_pressed():
	vinyl_select.emit()

func _on_cancel_pressed():
	vinyl_cancel.emit()

func set_instructions(text: String) -> void:
	if content:
		content.set_instructions(text)

func show_vinyl_inspection(vinyl: SimpleVinyl) -> void:
	if vinyl_container:
		vinyl_container.visible = true
		_update_vinyl_info(vinyl)
	# Hide rotation buttons during inspection
	if rotation_container:
		rotation_container.visible = false

func hide_vinyl_inspection() -> void:
	if vinyl_container:
		vinyl_container.visible = false
	# Show rotation buttons again
	if rotation_container:
		rotation_container.visible = true

func _update_vinyl_info(vinyl: SimpleVinyl) -> void:
	if vinyl_info_label and vinyl:
		var current = vinyl.get_current_song()
		var current_side = vinyl.get_current_side_name()
		
		var text = "[center][b]Lado %s[/b]\n%s\n[i]%s[/i][/center]" % [
			current_side,
			current.artist if current else "?",
			current.title if current else "?"
		]
		vinyl_info_label.text = text

func update_vinyl_display(vinyl: SimpleVinyl) -> void:
	## Call this after flipping to update the display
	_update_vinyl_info(vinyl)
