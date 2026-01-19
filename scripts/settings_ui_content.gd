extends Control
class_name SettingsUIContent

signal started

# Modal screens (intro)
@onready var modal_background: ColorRect = $ModalBackground
@onready var modal_container: CenterContainer = $ModalContainer
@onready var welcome_screen: VBoxContainer = $ModalContainer/ModalPanel/MarginContainer/ModalContent/WelcomeScreen
@onready var continue_button: Button = $ModalContainer/ModalPanel/MarginContainer/ModalContent/WelcomeScreen/ContinueButton
@onready var steps_screen: VBoxContainer = $ModalContainer/ModalPanel/MarginContainer/ModalContent/StepsScreen
@onready var start_button: Button = $ModalContainer/ModalPanel/MarginContainer/ModalContent/StepsScreen/StartButton

# Objective indicator (gameplay)
@onready var objective_container: Control = $ObjectiveContainer
@onready var objective_label: RichTextLabel = $ObjectiveContainer/ObjectivePanel/MarginContainer/HBoxContainer/ObjectiveLabel
@onready var restart_button: Button = $ObjectiveContainer/ObjectivePanel/MarginContainer/HBoxContainer/RestartButton


func _ready() -> void:
	continue_button.pressed.connect(_on_continue_pressed)
	start_button.pressed.connect(_on_start_pressed)
	restart_button.pressed.connect(_on_restart_pressed)


func set_instructions(text: String) -> void:
	if objective_label:
		objective_label.text = text


func _on_continue_pressed() -> void:
	welcome_screen.visible = false
	steps_screen.visible = true


func _on_start_pressed() -> void:
	print("Start pressed - emitting started signal")
	# Hide the modal
	modal_background.visible = false
	modal_container.visible = false
	# Show the objective indicator
	objective_container.visible = true
	started.emit()


func _on_restart_pressed() -> void:
	if is_inside_tree() and get_tree():
		get_tree().reload_current_scene()
