extends GameState

## Vinyl spinning - vinyl is spinning, can engage brake to stop

var _current_vinyl: SimpleVinyl = null
var _spin_speed: float = 0.1  # rotations per second (6 RPM - slow vinyl speed)
var _is_spinning: bool = false

func enter_state():
	print("Entered: VinylSpinning")
	_is_spinning = true
	
	# Disable all interactions first
	if gramophone:
		gramophone.disable_all_interactables()
	
	_current_vinyl = gramophone.mounted_vinyl if gramophone else null
	
	# Disable vinyl outline when spinning
	if _current_vinyl:
		_current_vinyl.set_interactable(false)
	
	# Enable brake - red = back (engage to stop)
	if gramophone and gramophone.brake:
		gramophone.brake.set_outline_color(GameColors.OUTLINE_DISASSEMBLE)
		gramophone.brake.set_interactable(true)
		gramophone.brake.engaged.connect(_on_brake_engaged)
	
	if gramophone:
		gramophone.set_instructions("", "Activa el freno para detener el vinilo")

func exit_state():
	_is_spinning = false
	
	if gramophone and gramophone.brake:
		if gramophone.brake.engaged.is_connected(_on_brake_engaged):
			gramophone.brake.engaged.disconnect(_on_brake_engaged)
		gramophone.brake.set_interactable(false)
	
	# Stop spinning
	_stop_vinyl_spin()

func _process(delta: float):
	if _is_spinning and _current_vinyl:
		# Rotate vinyl around Y axis (or its snap_pivot if it exists)
		var target_node = _current_vinyl.snap_pivot if _current_vinyl.snap_pivot else _current_vinyl
		target_node.rotate_y(_spin_speed * TAU * delta)

func _on_brake_engaged():
	print("Brake engaged - stopping vinyl spin")
	_is_spinning = false
	goto("BrakeReady")

func _stop_vinyl_spin():
	# Ensure spinning stops
	_is_spinning = false
