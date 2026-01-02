@tool
extends XRToolsSnapZone
class_name VinylSnapZone

@export var label: Label3D

var vinyl: Vinyl = null


func pick_up_object(target: Node3D) -> void:
	if not target is Vinyl:
		return
	
	vinyl = target as Vinyl

	# Let XRTools handle position snapping
	super.pick_up_object(target)

	# Optional debug label showing current song title
	if label and is_instance_valid(vinyl):
		label.text = vinyl.song.title
