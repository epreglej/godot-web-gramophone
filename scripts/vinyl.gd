@tool
extends XRToolsPickable
class_name Vinyl

# dot > 0 → A up, dot < 0 → B up
const FLIP_THRESHOLD := 0.0  

enum VinylSide { SIDE_A, SIDE_B }

var _side: VinylSide = VinylSide.SIDE_A
var side: VinylSide:
	get:
		return _side
	set(value):
		_side = value

var song: AudioStream:
	get:
		return _song_a if side == VinylSide.SIDE_A else _song_b


@export_group("Side A")
@export var _song_a: AudioStream
@export var _title_a: String = "Unknown Track"
@export var _artist_a: String = "Unknown Artist"
@export_group("Side B")
@export var _song_b: AudioStream
@export var _title_b: String = "Unknown Track B"
@export var _artist_b: String = "Unknown Artist B"


func _ready() -> void:
	enabled = false


func _physics_process(_delta: float) -> void:
	_update_side_from_orientation()


func _update_side_from_orientation() -> void:
	# Local "up" axis of the vinyl (its normal)
	var local_up := global_transform.basis.y.normalized()

	# Compare with world-up
	var dot := local_up.dot(Vector3.UP)

	# Decide which side faces up
	var new_side := VinylSide.SIDE_A if dot > FLIP_THRESHOLD else VinylSide.SIDE_B

	if new_side != _side:
		_side = new_side
