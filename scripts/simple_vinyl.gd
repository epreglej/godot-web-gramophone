extends RigidBody3D
class_name SimpleVinyl

## Vinyl with two-sided songs and inspection mode
## Click to inspect, then use UI to flip/select/cancel

signal inspection_started(vinyl: SimpleVinyl)
signal inspection_ended(vinyl: SimpleVinyl)
signal side_selected(vinyl: SimpleVinyl, song: Song)
signal cancelled(vinyl: SimpleVinyl)

@export var song_a: Song  # Side A song (was _song_a)
@export var song_b: Song  # Side B song (was _song_b)
@export var outline: Node3D
@export var snap_pivot: Node3D  # The pivot containing model/outline for rotation

var enabled: bool = false
var is_inspecting: bool = false
var current_side: int = 0  # 0 = A, 1 = B

var _home_transform: Transform3D  # Where the vinyl lives when not mounted (set once in _ready)
var _inspection_start_transform: Transform3D  # Where vinyl was when inspection started
var _stashed_snap_zone: Node3D = null  # Reference to home snap zone

func _ready():
	_home_transform = global_transform
	_inspection_start_transform = global_transform
	freeze = true
	_set_outline_visibility(false)

func _set_outline_visibility(value: bool):
	if outline:
		outline.visible = value

func set_interactable(value: bool):
	enabled = value
	_set_outline_visibility(value)

func set_outline_color(color: Color):
	if not outline:
		return
	_set_shader_color_recursive(outline, color)

func _set_shader_color_recursive(node: Node, color: Color):
	if node is MeshInstance3D:
		var mesh_instance := node as MeshInstance3D
		for i in range(mesh_instance.get_surface_override_material_count()):
			var mat = mesh_instance.get_surface_override_material(i)
			if mat is ShaderMaterial:
				mat.set_shader_parameter("shell_color", color)
		if mesh_instance.mesh:
			for i in range(mesh_instance.mesh.get_surface_count()):
				var mat = mesh_instance.mesh.surface_get_material(i)
				if mat is ShaderMaterial:
					mat.set_shader_parameter("shell_color", color)
	for child in node.get_children():
		_set_shader_color_recursive(child, color)

func can_grab() -> bool:
	## Used by MouseController to check if this can be interacted with
	return enabled and not is_inspecting

func on_grab():
	## Called when clicked - start inspection mode
	start_inspection()

func start_inspection():
	if is_inspecting:
		return
	
	is_inspecting = true
	_inspection_start_transform = global_transform  # Remember where we were (could be mounted or stashed)
	_set_outline_visibility(false)
	
	inspection_started.emit(self)

func end_inspection():
	is_inspecting = false
	inspection_ended.emit(self)

func flip():
	## Flip the vinyl to the other side
	if not is_inspecting:
		return
	
	current_side = 1 - current_side  # Toggle between 0 and 1
	
	# Rotate the snap_pivot (or self) 180 degrees to show other side
	var target = snap_pivot if snap_pivot else self
	var tween = create_tween()
	var target_rotation = target.rotation
	target_rotation.z += PI  # Flip around Z axis (vinyl surface normal)
	tween.tween_property(target, "rotation", target_rotation, 0.3).set_ease(Tween.EASE_OUT)

func select_current_side():
	## Confirm selection of current side
	var selected_song = song_a if current_side == 0 else song_b
	# MUST call end_inspection BEFORE emitting signal, otherwise is_inspecting
	# will still be true when the next state tries to enable the vinyl
	end_inspection()
	side_selected.emit(self, selected_song)

func cancel_inspection():
	## Cancel and return vinyl to HOME position (stashed, not mounted)
	# MUST call end_inspection BEFORE emitting signal
	end_inspection()
	cancelled.emit(self)
	
	# Return to HOME position (where vinyl was originally before any mounting)
	var tween = create_tween()
	tween.tween_property(self, "global_transform", _home_transform, 0.3).set_ease(Tween.EASE_OUT)
	
	# Show outline if still enabled
	if enabled:
		tween.tween_callback(func(): _set_outline_visibility(true))

func move_to_inspect_position(camera: Camera3D):
	## Animate vinyl to inspection position in front of camera
	if not camera:
		return
	
	# Position in front of camera
	var camera_forward = -camera.global_transform.basis.z
	var inspect_pos = camera.global_position + camera_forward * 0.5 + Vector3(0, -0.1, 0)
	
	# Create target transform facing camera
	var target_transform = Transform3D()
	target_transform.origin = inspect_pos
	# Orient to face camera with vinyl surface visible
	target_transform.basis = Basis.looking_at(-camera_forward, Vector3.UP)
	# Rotate to show the vinyl surface (lay flat facing camera)
	target_transform.basis = target_transform.basis.rotated(Vector3.RIGHT, -PI/2)
	
	var tween = create_tween()
	tween.tween_property(self, "global_transform", target_transform, 0.3).set_ease(Tween.EASE_OUT)

func move_to_position(target_pos: Vector3, target_basis: Basis = Basis.IDENTITY):
	## Animate vinyl to a specific position
	var target_transform = Transform3D(target_basis, target_pos)
	var tween = create_tween()
	tween.tween_property(self, "global_transform", target_transform, 0.3).set_ease(Tween.EASE_OUT)

func get_current_song() -> Song:
	return song_a if current_side == 0 else song_b

func get_other_song() -> Song:
	return song_b if current_side == 0 else song_a

func get_current_side_name() -> String:
	return "A" if current_side == 0 else "B"

func get_song_info() -> String:
	var song = get_current_song()
	if song:
		return "Side %s: %s - %s" % [get_current_side_name(), song.artist, song.title]
	return "Side %s: Unknown" % get_current_side_name()

func get_other_side_info() -> String:
	var song = get_other_song()
	var other_side = "B" if current_side == 0 else "A"
	if song:
		return "Side %s: %s - %s" % [other_side, song.artist, song.title]
	return "Side %s: Unknown" % other_side

func set_stashed_snap_zone(zone: Node3D):
	_stashed_snap_zone = zone

func return_to_stash():
	## Return vinyl to its home/stashed position
	if _stashed_snap_zone:
		move_to_position(_stashed_snap_zone.global_position, Basis.IDENTITY)
	else:
		# Return to home transform
		var tween = create_tween()
		tween.tween_property(self, "global_transform", _home_transform, 0.3).set_ease(Tween.EASE_OUT)
	
	if enabled:
		var tween2 = create_tween()
		tween2.tween_interval(0.3)
		tween2.tween_callback(func(): _set_outline_visibility(true))
