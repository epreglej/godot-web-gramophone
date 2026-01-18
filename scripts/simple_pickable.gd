extends RigidBody3D
class_name SimplePickable

## Simple pickable object that can be grabbed and dropped
## Add to any RigidBody3D with a CollisionShape3D

signal picked_up
signal dropped
signal entered_snap_zone(zone: Area3D)

@export var enabled: bool = false
@export var drag_height: float = 0.08  # Height above the original position to drag at
@export var outline: Node3D
@export var snap_distance: float = 0.15  # Distance to detect snap zones

var is_held: bool = false
var _original_freeze: bool = false
var _original_position: Vector3  # Store original position for reference
var _drag_plane_y: float = 0.0  # Y position of the drag plane

func _ready():
	_original_freeze = freeze
	_original_position = global_position
	_set_outline_visibility(false)

func _set_outline_visibility(value: bool):
	if outline:
		outline.visible = value
		print("Outline visibility set to: ", value, " (outline: ", outline.name, ")")

func set_interactable(value: bool):
	enabled = value
	_set_outline_visibility(value)

func set_outline_visible(value: bool):
	_set_outline_visibility(value)

func can_grab() -> bool:
	return enabled and not is_held

func on_grab():
	is_held = true
	_original_freeze = freeze
	freeze = true
	# Use fixed drag plane based on original position, not current
	_drag_plane_y = _original_position.y + drag_height
	_set_outline_visibility(false)
	picked_up.emit()

func on_release():
	is_held = false
	freeze = _original_freeze
	
	# Check for nearby snap zones and try to snap
	var snap_zone = _find_nearest_snap_zone()
	if snap_zone and snap_zone.has_method("try_snap"):
		print("Found snap zone: ", snap_zone.name, " - trying to snap")
		if snap_zone.try_snap(self):
			# Successfully snapped - zone will handle position
			entered_snap_zone.emit(snap_zone)
			dropped.emit()
			return
	
	# Not snapped - show outline if enabled
	if enabled:
		_set_outline_visibility(true)
	
	dropped.emit()

func _find_nearest_snap_zone() -> Area3D:
	# Find all snap zones by searching the tree
	var snap_zones: Array[Node] = []
	_find_snap_zones_recursive(get_tree().root, snap_zones)
	
	print("Found ", snap_zones.size(), " snap zones total")
	
	var nearest: Area3D = null
	var nearest_dist: float = snap_distance
	
	for zone in snap_zones:
		if zone is Area3D:
			# Check if zone is enabled
			var zone_enabled = zone.get("enabled") if "enabled" in zone else true
			var dist = global_position.distance_to(zone.global_position)
			print("  Snap zone: ", zone.name, " distance: ", "%.3f" % dist, " enabled: ", zone_enabled)
			
			if not zone_enabled:
				continue
			
			if dist < nearest_dist:
				nearest_dist = dist
				nearest = zone
	
	if nearest:
		print("  -> Nearest: ", nearest.name, " at distance: ", "%.3f" % nearest_dist)
	else:
		print("  -> No snap zone within range (", snap_distance, ")")
	
	return nearest

func _find_snap_zones_recursive(node: Node, result: Array[Node]):
	if node is Area3D and node.has_method("try_snap"):
		result.append(node)
	for child in node.get_children():
		_find_snap_zones_recursive(child, result)

func on_drag(mouse_pos: Vector2, _start_mouse: Vector2, camera: Camera3D):
	if not is_held or not camera:
		return
	
	# Project mouse onto a horizontal plane at the drag height
	var from = camera.project_ray_origin(mouse_pos)
	var direction = camera.project_ray_normal(mouse_pos)
	
	# Intersect ray with horizontal plane at _drag_plane_y
	# Plane equation: y = _drag_plane_y
	# Ray: P = from + t * direction
	# Solve: from.y + t * direction.y = _drag_plane_y
	if abs(direction.y) > 0.001:
		var t = (_drag_plane_y - from.y) / direction.y
		if t > 0:  # Only if intersection is in front of camera
			var intersection = from + direction * t
			global_position = intersection
