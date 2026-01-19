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
@export var collision_margin: float = 0.02  # Extra margin to prevent clipping into walls

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
			var target_pos = from + direction * t
			
			# Check for collision between current position and target
			var safe_pos = _check_movement_collision(global_position, target_pos)
			global_position = safe_pos

func _check_movement_collision(from_pos: Vector3, to_pos: Vector3) -> Vector3:
	## Check if movement would cause collision, return safe position
	var space_state = get_world_3d().direct_space_state
	
	# Raycast from current to target position
	var query = PhysicsRayQueryParameters3D.create(from_pos, to_pos)
	query.exclude = [get_rid()]  # Exclude self
	query.collision_mask = collision_mask  # Use our own collision mask
	
	var result = space_state.intersect_ray(query)
	
	if result:
		# Hit something - stop short of the collision point
		var hit_point = result.position
		var move_dir = (to_pos - from_pos).normalized()
		return hit_point - move_dir * collision_margin
	
	# No collision, safe to move
	return to_pos
