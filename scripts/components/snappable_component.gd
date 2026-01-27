extends Node
class_name SnappableComponent

## Handles snapping to snap zones
## Works with GrabbableComponent to snap objects when released

signal entered_snap_zone(zone: Area3D)

var _parent_body: RigidBody3D = null

func _ready():
	_parent_body = get_parent() as RigidBody3D
	if not _parent_body:
		push_error("SnappableComponent: Parent must be a RigidBody3D")
		return

func try_snap_on_release() -> bool:
	## Try to snap to a nearby snap zone when released
	## Returns true if successfully snapped
	if not _parent_body:
		return false
	
	var snap_zone = _find_overlapping_snap_zone()
	if snap_zone and snap_zone.has_method("try_snap"):
		print("Found overlapping snap zone: ", snap_zone.name, " - trying to snap")
		if snap_zone.try_snap(_parent_body):
			# Successfully snapped - zone will handle position
			entered_snap_zone.emit(snap_zone)
			return true
	
	return false

func _find_overlapping_snap_zone() -> Area3D:
	# Find all snap zones by searching the tree
	var snap_zones: Array[Node] = []
	_find_snap_zones_recursive(get_tree().root, snap_zones)
	
	print("Checking ", snap_zones.size(), " snap zones for overlap")
	
	var nearest_zone: Area3D = null
	var nearest_dist: float = INF
	
	for zone in snap_zones:
		if zone is Area3D:
			# Check if zone is enabled
			var zone_enabled = zone.get("enabled") if "enabled" in zone else true
			
			if not zone_enabled:
				print("  Snap zone: ", zone.name, " - skipped (disabled)")
				continue
			
			# Get the collision shape radius from the zone
			var snap_radius = _get_snap_zone_radius(zone)
			var dist = _parent_body.global_position.distance_to(zone.global_position)
			var is_overlapping = dist <= snap_radius
			
			print("  Snap zone: ", zone.name, " dist: %.3f" % dist, " radius: %.3f" % snap_radius, " overlapping: ", is_overlapping)
			
			# Only consider zones we're actually overlapping with, pick the nearest
			if is_overlapping and dist < nearest_dist:
				nearest_dist = dist
				nearest_zone = zone
	
	if nearest_zone:
		print("  -> Nearest overlapping zone: ", nearest_zone.name, " at dist: %.3f" % nearest_dist)
	else:
		print("  -> No overlapping snap zone found")
	
	return nearest_zone

func _get_snap_zone_radius(zone: Area3D) -> float:
	# Find the collision shape and get its radius
	for child in zone.get_children():
		if child is CollisionShape3D:
			var shape = child.shape
			if shape is SphereShape3D:
				return shape.radius
			elif shape is BoxShape3D:
				# Use the smallest dimension as an approximation
				return min(shape.size.x, shape.size.y, shape.size.z) / 2.0
			elif shape is CylinderShape3D:
				return shape.radius
	# Default fallback
	return 0.1

func _find_snap_zones_recursive(node: Node, result: Array[Node]):
	if node is Area3D and node.has_method("try_snap"):
		result.append(node)
	for child in node.get_children():
		_find_snap_zones_recursive(child, result)
