@tool
extends XRToolsPickable
class_name Vinyl

enum VinylSide { A, B }

@onready var snap_pivot: Node3D = $SnapPivot

@export var _song_a: Song
@export var _song_b: Song

var side: VinylSide = VinylSide.A
var song: Song:
	get:
		if side == VinylSide.A:
			return _song_a
		else:
			return _song_b


func update_side_before_snapping() -> void:
	# Use world-space up direction
	var vinyl_up: Vector3 = global_transform.basis.y
	var dot := vinyl_up.dot(Vector3.UP)
	
	side = VinylSide.A if dot > 0.0 else VinylSide.B


func pick_up(by: Node3D) -> void:
	if by is VinylSnapZone:
		update_side_before_snapping()
		super.pick_up(by)
		call_deferred("_apply_snap_orientation")
	else:
		super.pick_up(by)


func _apply_snap_orientation() -> void:
	if not is_instance_valid(snap_pivot):
		return
	
	snap_pivot.basis = Basis.IDENTITY
	
	if side == VinylSide.B:
		snap_pivot.basis = Basis(Vector3.FORWARD, PI)
