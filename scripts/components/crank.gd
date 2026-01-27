extends RigidBody3D
class_name Crank

## Coordinates all grabbable components together
## Attach to RigidBody3D that has GrabbableComponent, GrabbableSpaceLimiterComponent, SnappableComponent, and OutlineComponent

signal picked_up
signal dropped

@export var grabbable_component: GrabbableComponent
@export var grabbable_space_limiter_component: GrabbableSpaceLimiterComponent
@export var snappable_component: SnappableComponent
@export var outline_component: OutlineComponent

@export var animation_player: AnimationPlayer

func _ready():
	# Connect signals
	if grabbable_component:
		grabbable_component.picked_up.connect(_on_picked_up)
		grabbable_component.dropped.connect(_on_dropped)

func can_grab() -> bool:
	if grabbable_component:
		return grabbable_component.can_grab()
	return false

func on_grab():
	if grabbable_component:
		grabbable_component.on_grab()
	if grabbable_space_limiter_component:
		grabbable_space_limiter_component.start_drag()
	if outline_component:
		outline_component.set_outline_visible(false)

func on_release():
	if not grabbable_component:
		return
	
	grabbable_component.on_release()
	
	# Try to snap
	var snapped = false
	if snappable_component:
		snapped = snappable_component.try_snap_on_release()
		if snapped and grabbable_space_limiter_component:
			grabbable_space_limiter_component.reset_original_position()
	
	# Show outline if enabled and not snapped
	if not snapped and outline_component and grabbable_component.enabled:
		outline_component.set_outline_visible(true)

func on_drag(mouse_pos: Vector2, start_mouse: Vector2, camera: Camera3D):
	if not grabbable_component or not grabbable_space_limiter_component:
		return
	
	var drag_plane_y = grabbable_space_limiter_component.get_drag_plane_y()
	grabbable_component.on_drag(mouse_pos, start_mouse, camera, drag_plane_y)

func set_interactable(value: bool):
	if grabbable_component:
		grabbable_component.enabled = value
	if outline_component:
		outline_component.set_outline_visible(value)

func set_outline_color(color: Color):
	if outline_component:
		outline_component.set_outline_color(color)

func set_outline_visible(value: bool):
	if outline_component:
		outline_component.set_outline_visible(value)

func _on_picked_up():
	if outline_component:
		outline_component.set_outline_visible(false)
	picked_up.emit()

func _on_dropped():
	dropped.emit()
