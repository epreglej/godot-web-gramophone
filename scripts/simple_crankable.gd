extends Node3D
class_name SimpleCrankable

## Simple crankable that rotates when dragged and counts rotations

signal cranked  # Emitted when enough rotations completed

@export var enabled: bool = false
@export var rotations_required: float = 2.0
@export var sensitivity: float = 0.5
@export var outline: Node3D

var total_rotation: float = 0.0
var _is_grabbed: bool = false
var _last_mouse_x: float = 0.0

func _ready():
	if outline:
		outline.visible = false

func set_interactable(value: bool):
	enabled = value
	if outline:
		outline.visible = value

func can_grab() -> bool:
	return enabled

func on_grab():
	_is_grabbed = true
	_last_mouse_x = get_viewport().get_mouse_position().x

func on_release():
	_is_grabbed = false

func on_drag(mouse_pos: Vector2, _start_mouse: Vector2, _camera: Camera3D):
	if not _is_grabbed:
		return
	
	# Calculate mouse X movement for rotation
	var delta_x = mouse_pos.x - _last_mouse_x
	_last_mouse_x = mouse_pos.x
	
	# Rotate around Y axis (negative = clockwise)
	var rotation_delta = -delta_x * sensitivity
	rotate_y(deg_to_rad(rotation_delta))
	
	# Track total rotation (only count forward rotation)
	if rotation_delta > 0:
		total_rotation += rotation_delta
	
	# Check if enough rotations
	if total_rotation >= rotations_required * 360.0:
		cranked.emit()
