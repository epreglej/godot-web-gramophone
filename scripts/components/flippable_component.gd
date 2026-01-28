extends Node
class_name FlippableComponent

## Handles flipping between two sides (e.g., vinyl side A and B)

signal side_changed(new_side: int)

@export var flip_pivot: Node3D  # The node to rotate when flipping (usually a pivot containing model/outline)

var current_side: int = 0  # 0 = A, 1 = B

func _ready():
	if not flip_pivot:
		# Default to parent if no pivot specified
		flip_pivot = get_parent()

func flip():
	## Flip to the other side
	current_side = 1 - current_side  # Toggle between 0 and 1
	
	# Rotate the flip_pivot 180 degrees to show other side
	var target = flip_pivot if flip_pivot else get_parent()
	if not target:
		return
	
	var tween = target.create_tween()
	var target_rotation = target.rotation
	target_rotation.z += PI  # Flip around Z axis
	tween.tween_property(target, "rotation", target_rotation, 0.3).set_ease(Tween.EASE_OUT)
	
	side_changed.emit(current_side)

func get_current_side() -> int:
	return current_side

func get_current_side_name() -> String:
	return "A" if current_side == 0 else "B"

func get_other_side() -> int:
	return 1 - current_side

func get_other_side_name() -> String:
	return "B" if current_side == 0 else "A"
