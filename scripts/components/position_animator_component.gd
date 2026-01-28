extends Node
class_name PositionAnimatorComponent

## Handles smooth position/transform animations

var _parent_body: RigidBody3D = null

func _ready():
	_parent_body = get_parent() as RigidBody3D
	if not _parent_body:
		push_error("PositionAnimatorComponent: Parent must be a RigidBody3D")
		return

func move_to_position(target_pos: Vector3, target_basis: Basis = Basis.IDENTITY, duration: float = 0.3):
	## Animate object to a specific position
	if not _parent_body:
		return
	
	var target_transform = Transform3D(target_basis, target_pos)
	var tween = _parent_body.create_tween()
	tween.tween_property(_parent_body, "global_transform", target_transform, duration).set_ease(Tween.EASE_OUT)

func move_to_transform(target_transform: Transform3D, duration: float = 0.3):
	## Animate object to a specific transform
	if not _parent_body:
		return
	
	var tween = _parent_body.create_tween()
	tween.tween_property(_parent_body, "global_transform", target_transform, duration).set_ease(Tween.EASE_OUT)
