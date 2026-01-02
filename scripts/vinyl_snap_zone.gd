@tool
extends XRToolsSnapZone
class_name VinylSnapZone


@export var label: Label3D


var vinyl: Vinyl = null


func pick_up_object(target: Node3D) -> void:
	if not target is Vinyl:
		return
	
	vinyl = target as Vinyl
	
	vinyl.update_side_before_snapping()
	
	super.pick_up_object(target)
	
	if vinyl.side == Vinyl.VinylSide.B:
		vinyl.rotate(Vector3(1,0,0), PI)
	
	if label:
		label.text = vinyl.song.title
