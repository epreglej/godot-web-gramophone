extends Node
class_name ClickableComponent

## Pure clickable component - handles click detection without dragging
## Use this for objects that respond to clicks but don't need drag functionality

signal clicked

@export var enabled: bool = false

var _parent_body: RigidBody3D = null

func _ready():
	_parent_body = get_parent() as RigidBody3D
	if not _parent_body:
		push_error("ClickableComponent: Parent must be a RigidBody3D")
		return

func can_grab() -> bool:
	## Used by MouseController to check if this can be clicked
	return enabled and _parent_body != null

func on_grab():
	## Called when clicked - emit clicked signal
	clicked.emit()

func on_release():
	## Called when released - no-op for clickable
	pass

func on_drag(_mouse_pos: Vector2, _start_mouse: Vector2, _camera: Camera3D):
	## No-op for clickable (no dragging)
	pass
