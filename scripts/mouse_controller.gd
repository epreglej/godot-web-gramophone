extends Node3D
class_name MouseController

## Simple mouse controller for click-and-drag interactions
## Attach to root scene, it will handle all mouse input

@export var camera: Camera3D
@export var ray_length: float = 10.0

var _dragging: Node3D = null
var _drag_start_mouse: Vector2 = Vector2.ZERO
var _drag_start_position: Vector3 = Vector3.ZERO

func _ready():
	if not camera:
		camera = get_viewport().get_camera_3d()
	print("MouseController ready, camera: ", camera)
	print("MouseController is processing: ", is_processing())
	print("MouseController is processing input: ", is_processing_input())

func _input(event: InputEvent):
	if event is InputEventMouseButton:
		print("Mouse button event: ", event.button_index, " pressed: ", event.pressed)
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				_try_grab()
			else:
				_release()

func _process(_delta):
	if _dragging and _dragging.has_method("on_drag"):
		var mouse_pos = get_viewport().get_mouse_position()
		_dragging.on_drag(mouse_pos, _drag_start_mouse, camera)

func _try_grab():
	# Try multiple raycasts, skipping non-grabbable objects
	var exclude: Array[RID] = []
	var max_attempts = 10
	
	for attempt in range(max_attempts):
		var result = _raycast(exclude)
		if result.is_empty():
			print("Raycast hit nothing (attempt ", attempt + 1, ")")
			break
		
		var target = result.collider
		print("Raycast hit: ", target.name, " (", target.get_class(), ") - attempt ", attempt + 1)
		
		# Check the collider itself
		var grabbable = _find_grabbable(target)
		if grabbable and grabbable.can_grab():
			_start_drag(grabbable)
			return
		
		# Not grabbable - add to exclude list and try again
		if result.has("rid"):
			exclude.append(result.rid)
		else:
			# Fallback: exclude by collider
			exclude.append(target.get_rid())
		
		print("  -> Not grabbable, continuing raycast...")
	
	print("No grabbable object found after ", max_attempts, " attempts")

func _find_grabbable(target: Node3D) -> Node3D:
	## Find a grabbable node starting from target and checking parents
	# Check the target itself
	if target.has_method("on_grab") and target.has_method("can_grab"):
		return target
	
	# Check parents
	var parent = target.get_parent()
	while parent:
		if parent.has_method("on_grab") and parent.has_method("can_grab"):
			return parent
		parent = parent.get_parent()
	
	return null

func _start_drag(target: Node3D):
	_dragging = target
	_drag_start_mouse = get_viewport().get_mouse_position()
	_drag_start_position = target.global_position
	target.on_grab()
	print("Grabbed: ", target.name)

func _release():
	if _dragging:
		if _dragging.has_method("on_release"):
			_dragging.on_release()
		print("Released: ", _dragging.name)
		_dragging = null

func _raycast(exclude: Array[RID] = []) -> Dictionary:
	if not camera:
		return {}
	
	var mouse_pos = get_viewport().get_mouse_position()
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * ray_length
	
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(from, to)
	query.collision_mask = 0xFFFFFFFF  # All layers
	query.exclude = exclude
	
	return space_state.intersect_ray(query)

func get_mouse_world_position(distance: float = 2.0) -> Vector3:
	if not camera:
		return Vector3.ZERO
	
	var mouse_pos = get_viewport().get_mouse_position()
	var from = camera.project_ray_origin(mouse_pos)
	var direction = camera.project_ray_normal(mouse_pos)
	
	return from + direction * distance
