extends Node
class_name InspectableComponent

## Handles inspection mode - moving object to camera position for inspection

signal inspection_started
signal inspection_ended

var is_inspecting: bool = false
var _parent_body: RigidBody3D = null
var _home_transform: Transform3D
var _inspection_start_transform: Transform3D

func _ready():
	_parent_body = get_parent() as RigidBody3D
	if not _parent_body:
		push_error("InspectableComponent: Parent must be a RigidBody3D")
		return
	
	_home_transform = _parent_body.global_transform
	_inspection_start_transform = _parent_body.global_transform

func start_inspection():
	if is_inspecting:
		return
	
	is_inspecting = true
	_inspection_start_transform = _parent_body.global_transform
	inspection_started.emit()

func end_inspection():
	is_inspecting = false
	inspection_ended.emit()

func move_to_inspect_position(camera: Camera3D):
	## Animate object to inspection position in front of camera
	if not camera or not _parent_body:
		return
	
	# Position in front of camera
	var camera_forward = -camera.global_transform.basis.z
	var inspect_pos = camera.global_position + camera_forward * 0.5 + Vector3(0, -0.1, 0)
	
	# Create target transform facing camera
	var target_transform = Transform3D()
	target_transform.origin = inspect_pos
	# Orient to face camera with surface visible
	target_transform.basis = Basis.looking_at(-camera_forward, Vector3.UP)
	# Rotate to show the surface (lay flat facing camera)
	target_transform.basis = target_transform.basis.rotated(Vector3.RIGHT, -PI/2)
	
	var tween = _parent_body.create_tween()
	tween.tween_property(_parent_body, "global_transform", target_transform, 0.3).set_ease(Tween.EASE_OUT)

func get_home_transform() -> Transform3D:
	return _home_transform

func get_inspection_start_transform() -> Transform3D:
	return _inspection_start_transform
