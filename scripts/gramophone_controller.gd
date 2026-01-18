extends Node3D
class_name GramophoneController

## Main gramophone controller
## Uses a StateMachine child where each state is a child node

@export var state_machine: StateMachine
@export var ui: SettingsUI

# Components (set in editor or found automatically)
@export var lid: SimpleHinge
@export var audio_player: AudioStreamPlayer3D

# Crank components
@export var crank_pickable: SimplePickable
@export var mounted_crank_snap_zone: SimpleSnapZone
@export var stashed_crank_snap_zone: SimpleSnapZone

func _ready():
	# Find state machine if not set
	if not state_machine:
		state_machine = $StateMachine as StateMachine
	
	# Pass references to all states
	if state_machine:
		for child in state_machine.get_children():
			if child is GameState:
				child.gramophone = self
	
	# Connect to UI started signal
	if ui and ui.has_signal("started"):
		ui.started.connect(_on_ui_started)
	
	# Initialize crank in stashed position
	_setup_crank()

func _on_ui_started():
	print("UI started - transitioning to LidClosed")
	if state_machine:
		state_machine.change_state("LidClosed")

func set_instructions(text: String):
	if ui:
		ui.set_instructions(text)

func _setup_crank():
	# Place crank in stashed snap zone
	if crank_pickable and stashed_crank_snap_zone:
		crank_pickable.global_position = stashed_crank_snap_zone.global_position
		crank_pickable.set_interactable(false)
