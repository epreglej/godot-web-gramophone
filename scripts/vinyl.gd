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

# Called to detect which side is facing up
func update_side_from_current_rotation() -> void:
	if not is_instance_valid(snap_pivot):
		return
	# Use world-space up to determine which side is up
	var face_normal = global_transform.basis.y
	side = VinylSide.A if face_normal.dot(Vector3.UP) > 0.0 else VinylSide.B

# Only snap zone should force rotation
func _apply_snap_orientation() -> void:
	if not is_instance_valid(snap_pivot):
		return
	
	# Reset local rotation
	snap_pivot.basis = Basis.IDENTITY
	
	if side == VinylSide.B:
		# Flip over X axis (or Z if you prefer)
		snap_pivot.basis = Basis(Vector3.FORWARD, PI)

# Called when picked up
func pick_up(by: Node3D) -> void:
	if by is VinylSnapZone:
		# Side already updated in snap zone
		super.pick_up(by)
	else:
		# Hand pickup: remember current side but don't flip visually
		update_side_from_current_rotation()
		super.pick_up(by)
