extends Area3D
class_name SimpleSnapZone

## Simple snap zone that detects when pickable objects enter/exit
## Can be triggered by body_entered OR by manual try_snap() call

signal object_snapped(object: Node3D)
signal object_removed(object: Node3D)

@export var enabled: bool = false
@export var snap_group: String = ""  # Only snap objects in this group (empty = any)
@export var highlight_node: Node3D = null  # Optional highlight mesh
@export var snap_position: Node3D = null  # Optional target position for snapped object

var snapped_object: Node3D = null

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	# Hide highlight by default
	if highlight_node:
		highlight_node.visible = false

func set_active(value: bool):
	enabled = value
	print("SnapZone ", name, " set_active: ", value)
	# Show highlight when active and no object snapped
	if highlight_node:
		highlight_node.visible = value and snapped_object == null

func set_highlight_visible(value: bool):
	if highlight_node:
		highlight_node.visible = value

func set_highlight_color(color: Color):
	if not highlight_node or not highlight_node is MeshInstance3D:
		return
	
	var mesh_instance := highlight_node as MeshInstance3D
	
	# Get or create a unique material for this highlight
	var mat = mesh_instance.get_surface_override_material(0)
	if not mat:
		# Duplicate the mesh material
		if mesh_instance.mesh and mesh_instance.mesh.get_surface_count() > 0:
			var original = mesh_instance.mesh.surface_get_material(0)
			if original:
				mat = original.duplicate()
				mesh_instance.set_surface_override_material(0, mat)
	
	# Set the color on the material
	if mat and mat is StandardMaterial3D:
		mat.albedo_color = color

func try_snap(object: Node3D) -> bool:
	## Try to snap an object - called manually when object is released nearby
	print("SnapZone ", name, ": try_snap - ", object.name, " (enabled: ", enabled, ")")
	
	if not enabled:
		print("  -> Failed: not enabled")
		return false
	
	if snapped_object != null:
		print("  -> Failed: already has object")
		return false
	
	# Check if it's a pickable
	if not object.has_method("can_grab"):
		print("  -> Failed: no can_grab method")
		return false
	
	# Check group filter
	if snap_group != "" and not object.is_in_group(snap_group):
		print("  -> Failed: not in group '", snap_group, "'")
		return false
	
	print("  -> Success! Snapping.")
	_snap_object(object)
	return true

func _on_body_entered(body: Node3D):
	print("SnapZone ", name, ": body_entered - ", body.name, " (enabled: ", enabled, ")")
	
	if not enabled:
		print("  -> Ignored: not enabled")
		return
	
	if snapped_object != null:
		print("  -> Ignored: already has object")
		return  # Already have an object
	
	# Check if it's a pickable
	if not body.has_method("can_grab"):
		print("  -> Ignored: no can_grab method")
		return
	
	# Check group filter
	if snap_group != "" and not body.is_in_group(snap_group):
		print("  -> Ignored: not in group '", snap_group, "'")
		return
	
	print("  -> Snapping!")
	_snap_object(body)

func _on_body_exited(body: Node3D):
	if body == snapped_object:
		var old_object = snapped_object
		snapped_object = null
		object_removed.emit(old_object)
		
		if highlight_node and enabled:
			highlight_node.visible = true

func _snap_object(object: Node3D):
	snapped_object = object
	
	# Move object to snap position
	if snap_position:
		object.global_transform = snap_position.global_transform
	else:
		object.global_position = global_position
	
	# If pickable, release it
	if object.has_method("on_release") and object.has_method("is_held"):
		if object.is_held:
			object.on_release()
	
	object_snapped.emit(object)
	
	if highlight_node:
		highlight_node.visible = false

func has_object() -> bool:
	return snapped_object != null

func snap_object(object: Node3D):
	## Manually snap an object (for initial setup)
	_snap_object(object)

func release_object() -> Node3D:
	## Remove and return the snapped object
	var obj = snapped_object
	if obj:
		snapped_object = null
		object_removed.emit(obj)
	return obj

func clear():
	## Clear the snapped object reference without emitting signal
	## Use this when the object was picked up externally
	snapped_object = null
