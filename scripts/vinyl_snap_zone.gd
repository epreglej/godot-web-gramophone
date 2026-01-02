@tool
extends XRToolsSnapZone
class_name VinylSnapZone

@export var label: Label3D

var vinyl: Vinyl = null


func pick_up_object(target: Node3D) -> void:
	if not target is Vinyl:
		return

	vinyl = target as Vinyl

	# XRTools handles positioning
	super.pick_up_object(target)

	# Debug (optional)
	if label:
		label.text = vinyl.song.title
