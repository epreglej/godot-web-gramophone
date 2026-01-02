@tool
extends XRToolsPickable
class_name Vinyl


enum VinylSide { A, B }


@export var _song_a: Song
@export var _song_b: Song


var side: VinylSide = VinylSide.A
var song: Song:
	get:
		return _song_a if side == VinylSide.A else _song_b


# Update the side based on world rotation
func update_side_before_snapping() -> void:
	var up_vec := global_transform.basis.y
	side = VinylSide.A if up_vec.dot(Vector3.UP) > 0.0 else VinylSide.B
