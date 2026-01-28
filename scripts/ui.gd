extends CanvasLayer
class_name SettingsUI

signal started
signal rotate_camera(degrees: float)
signal vinyl_flip
signal vinyl_select
signal vinyl_cancel

@export var rotation_degrees: float = 15.0

@onready var rotation_container: Control = $RotationContainer
@onready var modal_background: ColorRect = $ModalBackground
@onready var modal_container: CenterContainer = $ModalContainer
@onready var welcome_screen: VBoxContainer = $ModalContainer/ModalPanel/MarginContainer/WelcomeScreen
@onready var continue_button: Button = $ModalContainer/ModalPanel/MarginContainer/WelcomeScreen/ContinueButton
@onready var steps_screen: VBoxContainer = $ModalContainer/ModalPanel/MarginContainer/StepsScreen
@onready var start_button: Button = $ModalContainer/ModalPanel/MarginContainer/StepsScreen/StartButton
@onready var objective_container: Control = $ObjectiveContainer
@onready var objective_label: RichTextLabel = $ObjectiveContainer/ObjectivePanel/MarginContainer/ObjectiveLabel
@onready var restart_button: Button = $RotationContainer/HBoxContainer/RestartButton
@onready var left_button: Button = $RotationContainer/HBoxContainer/LeftButton
@onready var right_button: Button = $RotationContainer/HBoxContainer/RightButton
@onready var vinyl_container: Control = $VinylContainer
@onready var vinyl_info_label: RichTextLabel = $VinylContainer/PanelContainer/MarginContainer/VBoxContainer/VinylInfoLabel
@onready var flip_button: Button = $VinylContainer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/FlipButton
@onready var select_button: Button = $VinylContainer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/SelectButton
@onready var cancel_button: Button = $VinylContainer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/CancelButton

func _ready():
	# Connect modal buttons
	if continue_button:
		continue_button.pressed.connect(_on_continue_pressed)
	if start_button:
		start_button.pressed.connect(_on_start_pressed)
	if restart_button:
		restart_button.pressed.connect(_on_restart_pressed)
	
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
	
	# Hide vinyl container, rotation arrows, and objective container by default
	if vinyl_container:
		vinyl_container.visible = false
	if rotation_container:
		rotation_container.visible = false
	if objective_container:
		objective_container.visible = false
	
	# Initial positioning
	_update_ui_positions()
	
	# Update when window resizes
	get_tree().root.size_changed.connect(_update_ui_positions)

func _update_ui_positions():
	var viewport_size = get_viewport().get_visible_rect().size
	
	# Position rotation buttons at bottom center
	if rotation_container:
		var button_width = 200.0
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

func _on_start_pressed() -> void:
	print("Start pressed - emitting started signal")
	# Hide the modal
	if modal_background:
		modal_background.visible = false
	if modal_container:
		modal_container.visible = false
	# Show the objective indicator
	if objective_container:
		objective_container.visible = true
	# Show rotation arrows when game starts
	if rotation_container:
		rotation_container.visible = true
	started.emit()

func _on_continue_pressed() -> void:
	if welcome_screen:
		welcome_screen.visible = false
	if steps_screen:
		steps_screen.visible = true

func _on_restart_pressed() -> void:
	if is_inside_tree() and get_tree():
		get_tree().reload_current_scene()

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

func set_instructions(assemble_text: String = "", disassemble_text: String = "") -> void:
	if objective_label:
		var text_parts = []
		
		if assemble_text != "":
			text_parts.append("Para montar:\n[color=#66cc88]%s[/color]" % assemble_text)
		
		if disassemble_text != "":
			if text_parts.size() > 0:
				text_parts.append("\n")
			text_parts.append("Para desmontar:\n[color=#d9887a]%s[/color]" % disassemble_text)
		
		objective_label.text = "".join(text_parts)
		# Use call_deferred to resize after text layout updates
		call_deferred("_resize_objective_container")

func _resize_objective_container() -> void:
	if objective_container and objective_label:
		# Get the actual size of the label after layout
		var label_height = objective_label.get_content_height()
		var label_width = objective_label.get_content_width()
		# Calculate container size: label size + margins (16px each side)
		var min_height = max(60.0, label_height + 24.0) # 24px for top/bottom margins
		var min_width = max(300.0, label_width + 32.0) # 32px for left/right margins
		objective_container.size = Vector2(min_width, min_height)

func show_vinyl_inspection(vinyl: Vinyl) -> void:
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

func _update_vinyl_info(vinyl: Vinyl) -> void:
	if vinyl_info_label and vinyl:
		var current = vinyl.get_current_song()
		var current_side = vinyl.get_current_side_name()
		
		var text = "[center][b]Lado %s[/b]\n%s\n[i]%s[/i][/center]" % [
			current_side,
			current.artist if current else "?",
			current.title if current else "?"
		]
		vinyl_info_label.text = text

func update_vinyl_display(vinyl: Vinyl) -> void:
	## Call this after flipping to update the display
	_update_vinyl_info(vinyl)
