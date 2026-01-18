extends Node3D
class_name SimpleHinge

## Simple hinge that rotates when dragged
## Add a CollisionShape3D child to make it grabbable

signal opened
signal closed

@export var enabled: bool = false
@export var min_angle: float = 0.0
@export var max_angle: float = 90.0
@export var open_threshold: float = 35.0
@export var close_threshold: float = 55.0
@export var sensitivity: float = 0.3  # How much mouse movement affects rotation
@export var outline: Node3D
@export var animation_player: AnimationPlayer

var angle: float = 0.0:
	set(value):
		angle = value
		_apply_rotation()
var _is_grabbed: bool = false
var _last_mouse_y: float = 0.0
var _initial_basis: Basis
var _is_animating: bool = false

func _ready():
	_initial_basis = transform.basis
	# Hide outline by default
	if outline:
		outline.visible = false

func set_interactable(value: bool):
	enabled = value
	if outline:
		outline.visible = value

func set_outline_visible(visible: bool):
	if outline:
		outline.visible = visible

func play_animation(animation_name: String):
	if not animation_player or not animation_player.has_animation(animation_name):
		return
	
	_is_animating = true
	set_interactable(false)
	
	animation_player.play(animation_name)
	await animation_player.animation_finished
	
	_is_animating = false

func can_grab() -> bool:
	return enabled and not _is_animating

func on_grab():
	_is_grabbed = true
	_last_mouse_y = get_viewport().get_mouse_position().y

func on_release():
	_is_grabbed = false

func on_drag(mouse_pos: Vector2, _start_mouse: Vector2, _camera: Camera3D):
	if not _is_grabbed or _is_animating:
		return
	
	# Calculate mouse Y movement (up = open lid, down = close lid)
	var delta_y = _last_mouse_y - mouse_pos.y  # Inverted: drag up = positive
	_last_mouse_y = mouse_pos.y
	
	# Update angle
	var new_angle = angle + delta_y * sensitivity
	set_angle(new_angle)

func set_angle(new_angle: float):
	new_angle = clamp(new_angle, min_angle, max_angle)
	
	if abs(new_angle - angle) < 0.01:
		return
	
	var old_angle = angle
	angle = new_angle  # Setter triggers _apply_rotation()
	
	# Check thresholds and emit signals (only when crossing threshold)
	if old_angle < open_threshold and angle >= open_threshold:
		opened.emit()
	elif old_angle > close_threshold and angle <= close_threshold:
		closed.emit()

func _apply_rotation():
	if _initial_basis == Basis():
		return
	var hinge_rotation = Basis(Vector3.RIGHT, deg_to_rad(-angle))
	transform.basis = _initial_basis * hinge_rotation
