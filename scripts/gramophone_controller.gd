extends Node3D
class_name GramophoneController

## Main gramophone controller
## Uses a StateMachine child where each state is a child node

@export var state_machine: StateMachine
@export var ui: SettingsUI
@export var camera: Camera3D

# Components (set in editor or found automatically)
@export var lid: SimpleHinge
@export var audio_player: AudioStreamPlayer3D

# Crank components
@export var crank_pickable: SimplePickable
@export var mounted_crank_snap_zone: SimpleSnapZone
@export var stashed_crank_snap_zone: SimpleSnapZone

# Filter components
@export var filter_pickable: SimplePickable
@export var mounted_filter_snap_zone: SimpleSnapZone
@export var stashed_filter_snap_zone: SimpleSnapZone

# Vinyl components
@export var mounted_vinyl_snap_zone: Node3D  # Position for vinyl on turntable
var vinyls: Array[SimpleVinyl] = []  # Found automatically by group

# Vinyl state
var inspecting_vinyl: SimpleVinyl = null
var mounted_vinyl: SimpleVinyl = null
var selected_song: Song = null

# Camera rotation
var _camera_rotation_target: float = 0.0
var _camera_rotation_speed: float = 5.0

func _ready():
	# Find state machine if not set
	if not state_machine:
		state_machine = $StateMachine as StateMachine
	
	# Pass references to all states
	if state_machine:
		for child in state_machine.get_children():
			if child is GameState:
				child.gramophone = self
	
	# Connect to UI signals
	if ui:
		if ui.has_signal("started"):
			ui.started.connect(_on_ui_started)
		if ui.has_signal("rotate_camera"):
			ui.rotate_camera.connect(_on_rotate_camera)
		if ui.has_signal("vinyl_flip"):
			ui.vinyl_flip.connect(_on_vinyl_flip)
		if ui.has_signal("vinyl_select"):
			ui.vinyl_select.connect(_on_vinyl_select)
		if ui.has_signal("vinyl_cancel"):
			ui.vinyl_cancel.connect(_on_vinyl_cancel)
	
	# Initialize crank in stashed position
	_setup_crank()
	
	# Find all vinyls by group
	_find_vinyls()

func _process(delta: float):
	# Smooth camera rotation
	if camera:
		var current_y = camera.rotation_degrees.y
		if abs(current_y - _camera_rotation_target) > 0.1:
			camera.rotation_degrees.y = lerp(current_y, _camera_rotation_target, delta * _camera_rotation_speed)

func _on_ui_started():
	print("UI started - transitioning to LidClosed")
	if state_machine:
		state_machine.change_state("LidClosed")

func _on_rotate_camera(degrees: float):
	print("_on_rotate_camera called with degrees: ", degrees, ", camera: ", camera)
	_camera_rotation_target += degrees
	# Clamp rotation to reasonable range (-45 to 45 degrees)
	_camera_rotation_target = clamp(_camera_rotation_target, -45.0, 45.0)
	print("New _camera_rotation_target: ", _camera_rotation_target)

func _on_vinyl_flip():
	# Forward to current state if it handles vinyl inspection
	var current_state = state_machine.get_current_state() if state_machine else null
	if current_state and current_state.has_method("flip_vinyl"):
		current_state.flip_vinyl()

func _on_vinyl_select():
	var current_state = state_machine.get_current_state() if state_machine else null
	if current_state and current_state.has_method("select_vinyl"):
		current_state.select_vinyl()

func _on_vinyl_cancel():
	var current_state = state_machine.get_current_state() if state_machine else null
	if current_state and current_state.has_method("cancel_inspection"):
		current_state.cancel_inspection()

func set_instructions(assemble_text: String = "", disassemble_text: String = ""):
	if ui:
		ui.set_instructions(assemble_text, disassemble_text)

func disable_all_interactables():
	## Disables ALL interactive components and snap zones
	## Call this at the start of each state to ensure a clean slate
	
	# Lid
	if lid:
		lid.set_interactable(false)
	
	# Crank
	if crank_pickable:
		crank_pickable.set_interactable(false)
	if mounted_crank_snap_zone:
		mounted_crank_snap_zone.set_active(false)
	if stashed_crank_snap_zone:
		stashed_crank_snap_zone.set_active(false)
	
	# Filter
	if filter_pickable:
		filter_pickable.set_interactable(false)
	if mounted_filter_snap_zone:
		mounted_filter_snap_zone.set_active(false)
	if stashed_filter_snap_zone:
		stashed_filter_snap_zone.set_active(false)
	
	# Vinyls
	for vinyl in vinyls:
		if vinyl:
			vinyl.set_interactable(false)

func _setup_crank():
	# Place crank in stashed snap zone
	if crank_pickable and stashed_crank_snap_zone:
		crank_pickable.global_position = stashed_crank_snap_zone.global_position
		crank_pickable.set_interactable(false)

func _find_vinyls():
	# Find all nodes in the "Vinyls" group that are children of this node
	vinyls.clear()
	for child in get_children():
		if child is SimpleVinyl and child.is_in_group("Vinyls"):
			vinyls.append(child)
			child.set_interactable(false)
	print("Found ", vinyls.size(), " vinyls")
