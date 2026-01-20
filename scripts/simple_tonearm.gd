extends Node3D
class_name SimpleTonearm

## Tonearm that works like a hinge:
## - Drag to rotate within angle limits
## - Emits `mounted` when moved over the record
## - Emits `stowed` when returned to its rest position

signal mounted   ## Emitted when tonearm is moved onto the record (start playback)
signal stowed    ## Emitted when tonearm is moved back to rest (stop playback)

@export var enabled: bool = false
@export var outline: Node3D
@export var animation_player: AnimationPlayer

@export var min_angle: float = 0.0         ## Rest position (degrees)
@export var max_angle: float = 35.0        ## Over-record position (degrees)
@export var mount_threshold: float = 20.0  ## Angle at which we consider it "mounted"
@export var stow_threshold: float = 30.0   ## Angle at which we consider it "stowed"
@export var sensitivity: float = 0.3       ## Mouse drag sensitivity

var angle: float = 0.0:
	set(value):
		var clamped = clamp(value, min_angle, max_angle)
		if abs(clamped - angle) < 0.001:
			return
		var prev = angle
		angle = clamped
		_apply_rotation()
		# Only evaluate thresholds for user-driven changes (not during animations)
		if not _is_animating:
			_check_mount_state(prev, angle)

var is_mounted: bool = false
var _initial_basis: Basis
var _is_grabbed: bool = false
var _last_mouse_y: float = 0.0
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

func set_outline_color(color: Color):
	if not outline:
		return
	_set_shader_color_recursive(outline, color)

func _set_shader_color_recursive(node: Node, color: Color):
	if node is MeshInstance3D:
		var mesh_instance := node as MeshInstance3D
		# Check surface material overrides first
		for i in range(mesh_instance.get_surface_override_material_count()):
			var mat = mesh_instance.get_surface_override_material(i)
			if mat is ShaderMaterial:
				mat.set_shader_parameter("shell_color", color)
		# Also check mesh materials
		if mesh_instance.mesh:
			for i in range(mesh_instance.mesh.get_surface_count()):
				var mat = mesh_instance.mesh.surface_get_material(i)
				if mat is ShaderMaterial:
					mat.set_shader_parameter("shell_color", color)
	# Recurse into children
	for child in node.get_children():
		_set_shader_color_recursive(child, color)

func can_grab() -> bool:
	return enabled and not _is_animating

func on_grab():
	_is_grabbed = true
	var mp := get_viewport().get_mouse_position()
	_last_mouse_y = mp.y

func on_release():
	_is_grabbed = false

func on_drag(mouse_pos: Vector2, _start_mouse: Vector2, _camera: Camera3D):
	if not _is_grabbed or not enabled or _is_animating:
		return
	# Hinge-like: use vertical movement only, but inverted vs lid:
	# drag DOWN to move onto record (increase angle), UP to stow (decrease angle)
	var dy = mouse_pos.y - _last_mouse_y  # down = positive
	_last_mouse_y = mouse_pos.y
	angle += dy * sensitivity

func _apply_rotation():
	if _initial_basis == Basis():
		return
	# Rotate around local Y axis so the arm swings horizontally over the record
	var rot = Basis(Vector3.UP, deg_to_rad(angle))
	transform.basis = _initial_basis * rot

func _check_mount_state(prev_angle: float, new_angle: float):
	# Mount when crossing 20° upwards
	if not is_mounted and prev_angle < mount_threshold and new_angle >= mount_threshold:
		is_mounted = true
		_play_anim("Mounting")
		mounted.emit()
	# Stow when crossing 30° downwards
	elif is_mounted and prev_angle > stow_threshold and new_angle <= stow_threshold:
		is_mounted = false
		_play_anim("Stowing")
		stowed.emit()

func _play_anim(name: String):
	if not animation_player or not animation_player.has_animation(name):
		return
	_is_animating = true
	_is_grabbed = false
	animation_player.play(name)
	await animation_player.animation_finished
	_is_animating = false
