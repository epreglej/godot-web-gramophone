extends RigidBody3D
class_name Vinyl

## Coordinates all vinyl components together
## Attach to RigidBody3D that has ClickableComponent, InspectableComponent, FlippableComponent, PositionAnimatorComponent, SnappableComponent, and OutlineComponent

signal inspection_started(vinyl: Vinyl)
signal inspection_ended(vinyl: Vinyl)
signal side_selected(vinyl: Vinyl, song: Song)
signal cancelled(vinyl: Vinyl)

@export var song_a: Song
@export var song_b: Song

@export var clickable_component: ClickableComponent
@export var inspectable_component: InspectableComponent
@export var flippable_component: FlippableComponent
@export var position_animator_component: PositionAnimatorComponent
@export var snappable_component: SnappableComponent
@export var outline_component: OutlineComponent

@export var rotation_pivot: Node3D


var enabled: bool = false
var _stashed_snap_zone: Node3D = null

func _ready():
	freeze = true
	
	# Connect signals
	if clickable_component:
		clickable_component.clicked.connect(_on_clicked)
	if inspectable_component:
		inspectable_component.inspection_started.connect(_on_inspection_started)
		inspectable_component.inspection_ended.connect(_on_inspection_ended)
	if flippable_component:
		flippable_component.side_changed.connect(_on_side_changed)

func can_grab() -> bool:
	if clickable_component:
		return clickable_component.can_grab()
	return false

func on_grab():
	if clickable_component:
		clickable_component.on_grab()

func on_release():
	if clickable_component:
		clickable_component.on_release()

func on_drag(_mouse_pos: Vector2, _start_mouse: Vector2, _camera: Camera3D):
	# Vinyl doesn't drag
	pass

func set_interactable(value: bool):
	enabled = value
	if clickable_component:
		clickable_component.enabled = value
	if outline_component:
		outline_component.set_outline_visible(value)

func set_outline_color(color: Color):
	if outline_component:
		outline_component.set_outline_color(color)

func set_outline_visible(value: bool):
	if outline_component:
		outline_component.set_outline_visible(value)

func start_inspection():
	if inspectable_component:
		inspectable_component.start_inspection()

func end_inspection():
	if inspectable_component:
		inspectable_component.end_inspection()

func flip():
	if flippable_component:
		flippable_component.flip()

func select_current_side():
	var selected_song = get_current_song()
	# MUST call end_inspection BEFORE emitting signal
	end_inspection()
	side_selected.emit(self, selected_song)

func cancel_inspection():
	# MUST call end_inspection BEFORE emitting signal
	end_inspection()
	cancelled.emit(self)
	
	# Return to HOME position
	if inspectable_component and position_animator_component:
		var home_transform = inspectable_component.get_home_transform()
		position_animator_component.move_to_transform(home_transform)
		
		# Show outline if still enabled
		if enabled:
			var tween = create_tween()
			tween.tween_interval(0.3)
			tween.tween_callback(func(): set_outline_visible(true))

func move_to_inspect_position(camera: Camera3D):
	if inspectable_component:
		inspectable_component.move_to_inspect_position(camera)

func move_to_position(target_pos: Vector3, target_basis: Basis = Basis.IDENTITY):
	if position_animator_component:
		position_animator_component.move_to_position(target_pos, target_basis)

func get_current_song() -> Song:
	var side = flippable_component.get_current_side() if flippable_component else 0
	return song_a if side == 0 else song_b

func get_other_song() -> Song:
	var side = flippable_component.get_current_side() if flippable_component else 0
	return song_b if side == 0 else song_a

func get_current_side_name() -> String:
	if flippable_component:
		return flippable_component.get_current_side_name()
	return "A"

func get_other_side_info() -> String:
	var song = get_other_song()
	var other_side = "B" if (flippable_component and flippable_component.get_current_side() == 0) else "A"
	if song:
		return "Side %s: %s - %s" % [other_side, song.artist, song.title]
	return "Side %s: Unknown" % other_side

func get_song_info() -> String:
	var song = get_current_song()
	var side_name = get_current_side_name()
	if song:
		return "Side %s: %s - %s" % [side_name, song.artist, song.title]
	return "Side %s: Unknown" % side_name

func set_stashed_snap_zone(zone: Node3D):
	_stashed_snap_zone = zone

func return_to_stash():
	if _stashed_snap_zone and position_animator_component:
		position_animator_component.move_to_position(_stashed_snap_zone.global_position, Basis.IDENTITY)
	elif inspectable_component and position_animator_component:
		var home_transform = inspectable_component.get_home_transform()
		position_animator_component.move_to_transform(home_transform)
	
	if enabled:
		var tween = create_tween()
		tween.tween_interval(0.3)
		tween.tween_callback(func(): set_outline_visible(true))

func _on_clicked():
	start_inspection()

func _on_inspection_started():
	if outline_component:
		outline_component.set_outline_visible(false)
	inspection_started.emit(self)

func _on_inspection_ended():
	inspection_ended.emit(self)

func _on_side_changed(_new_side: int):
	# Side changed - could emit signal if needed
	pass
