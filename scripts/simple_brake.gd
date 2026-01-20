extends Node3D
class_name SimpleBrake

## Simple brake that disengages on click
## When disengaged, allows vinyl to spin

signal disengaged
signal engaged

@export var enabled: bool = false
@export var outline: Node3D
@export var animation_player: AnimationPlayer

var angle: float = 0.0:
	set(value):
		angle = value
		_apply_rotation()

var is_disengaged: bool = false
var _is_animating: bool = false
var _initial_basis: Basis

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
	# Find all mesh instances in outline and set shader color
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
	# When clicked, toggle brake state
	if is_disengaged:
		engage()
	else:
		disengage()

func disengage():
	if is_disengaged or _is_animating:
		return
	
	_is_animating = true
	set_interactable(false)
	
	# Play disengaging animation
	if animation_player and animation_player.has_animation("Disengaging"):
		print("Playing Disengaging animation, current angle: ", angle)
		animation_player.play("Disengaging")
		await animation_player.animation_finished
		print("Animation finished, angle is now: ", angle)
	
	is_disengaged = true
	_is_animating = false
	disengaged.emit()

func engage():
	if not is_disengaged or _is_animating:
		return
	
	_is_animating = true
	set_interactable(false)
	
	# Play engaging animation
	if animation_player and animation_player.has_animation("Engaging"):
		animation_player.play("Engaging")
		await animation_player.animation_finished
	
	is_disengaged = false
	_is_animating = false
	engaged.emit()

func on_release():
	pass  # Not used for brake

func on_drag(_mouse_pos: Vector2, _start_mouse: Vector2, _camera: Camera3D):
	pass  # Not used for brake

func _apply_rotation():
	# Rotate around Y axis
	var brake_rotation = Basis(Vector3.UP, deg_to_rad(angle))
	transform.basis = _initial_basis * brake_rotation
