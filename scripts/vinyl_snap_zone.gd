@tool
extends XRToolsSnapZone
class_name VinylSnapZone

@export var label: Label3D

var vinyl: Vinyl = null

func pick_up_object(target: Node3D) -> void:
	if not target is Vinyl:
		return

	vinyl = target as Vinyl

	# Update side before applying snap rotation
	vinyl.update_side_from_current_rotation()

	# Let XRTools handle position/rotation
	super.pick_up_object(target)

	# Apply flip if side B
	if vinyl.side == Vinyl.VinylSide.B:
		vinyl._apply_snap_orientation()

	# Update UI label
	if label:
		label.text = vinyl.song.title
