extends Node
class_name GrabbableSpaceLimiterComponent

## Limits the space in which a grabbed object can be dragged
## Works with GrabbableComponent to provide drag_height functionality

@export var grab_height: float = 0.08  # Height above the original position to drag at

var _original_position: Vector3  # Store original position for reference
var _drag_plane_y: float = 0.0  # Y position of the drag plane
var _parent_body: RigidBody3D = null

func _ready():
	_parent_body = get_parent() as RigidBody3D
	if not _parent_body:
		push_error("GrabbableSpaceLimiterComponent: Parent must be a RigidBody3D")
		return
	
	_original_position = _parent_body.global_position

func get_drag_plane_y() -> float:
	## Returns the Y position of the drag plane
	return _drag_plane_y

func start_drag():
	## Call this when drag starts to set up the drag plane
	if _parent_body:
		# Use fixed drag plane based on original position, not current
		_drag_plane_y = _original_position.y + grab_height

func reset_original_position():
	## Call this to update the original position (e.g., after snapping)
	if _parent_body:
		_original_position = _parent_body.global_position
