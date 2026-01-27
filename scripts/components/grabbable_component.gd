extends Node
class_name GrabbableComponent

## Pure grabbable component - handles grab and drag functionality
## Attach to any RigidBody3D to make it grabbable

signal picked_up
signal dropped

@export var enabled: bool = false
@export var collision_margin: float = 0.02  # Extra margin to prevent clipping into walls

var is_held: bool = false
var _parent_body: RigidBody3D = null
var _original_freeze: bool = false

func _ready():
	_parent_body = get_parent() as RigidBody3D
	if not _parent_body:
		push_error("GrabbableComponent: Parent must be a RigidBody3D")
		return
	
	_original_freeze = _parent_body.freeze

func can_grab() -> bool:
	return enabled and not is_held and _parent_body != null

func on_grab():
	if not _parent_body:
		return
	
	is_held = true
	_original_freeze = _parent_body.freeze
	_parent_body.freeze = true
	# Reset rotation to identity (straighten the object)
	_parent_body.basis = Basis.IDENTITY
	picked_up.emit()

func on_release():
	if not _parent_body:
		return
	
	is_held = false
	_parent_body.freeze = _original_freeze
	dropped.emit()

func on_drag(mouse_pos: Vector2, _start_mouse: Vector2, camera: Camera3D, drag_plane_y: float):
	## Drag the object - requires drag_plane_y from space limiter
	if not is_held or not camera or not _parent_body:
		return
	
	# Project mouse onto a horizontal plane at the drag height
	var from = camera.project_ray_origin(mouse_pos)
	var direction = camera.project_ray_normal(mouse_pos)
	
	# Intersect ray with horizontal plane at drag_plane_y
	# Plane equation: y = drag_plane_y
	# Ray: P = from + t * direction
	# Solve: from.y + t * direction.y = drag_plane_y
	if abs(direction.y) > 0.001:
		var t = (drag_plane_y - from.y) / direction.y
		if t > 0:  # Only if intersection is in front of camera
			var target_pos = from + direction * t
			
			# Check for collision between current position and target
			var safe_pos = _check_movement_collision(_parent_body.global_position, target_pos)
			_parent_body.global_position = safe_pos

func _check_movement_collision(from_pos: Vector3, to_pos: Vector3) -> Vector3:
	## Check if movement would cause collision, return safe position
	if not _parent_body:
		return to_pos
		
	var space_state = _parent_body.get_world_3d().direct_space_state
	
	# Raycast from current to target position
	var query = PhysicsRayQueryParameters3D.create(from_pos, to_pos)
	query.exclude = [_parent_body.get_rid()]  # Exclude self
	query.collision_mask = _parent_body.collision_mask  # Use parent's collision mask
	
	var result = space_state.intersect_ray(query)
	
	if result:
		# Hit something - stop short of the collision point
		var hit_point = result.position
		var move_dir = (to_pos - from_pos).normalized()
		return hit_point - move_dir * collision_margin
	
	# No collision, safe to move
	return to_pos
