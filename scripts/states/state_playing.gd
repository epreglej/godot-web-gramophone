extends GameState

## Playing - vinyl is spinning and music is playing
## Only active step: stow the tonearm to return to VinylSpinning

var _current_vinyl: SimpleVinyl = null
var _spin_speed: float = 0.1  # same as VinylSpinning
var _is_spinning: bool = false

func enter_state():
	print("Entered: Playing")
	_is_spinning = true
	
	# Disable all interactions first
	if gramophone:
		gramophone.disable_all_interactables()
	
	_current_vinyl = gramophone.mounted_vinyl if gramophone else null
	
	# Enable tonearm as the only interactive element - red = back
	if gramophone and gramophone.tonearm:
		gramophone.tonearm.set_outline_color(GameColors.OUTLINE_DISASSEMBLE)
		gramophone.tonearm.set_interactable(true)
		if not gramophone.tonearm.stowed.is_connected(_on_tonearm_stowed):
			gramophone.tonearm.stowed.connect(_on_tonearm_stowed)
	
	# Start playback of the selected song (if any)
	if gramophone:
		gramophone.start_playback()
		gramophone.set_instructions("Disfruta de la música", "Devuelve el brazo para detener la música")

func exit_state():
	_is_spinning = false
	
	# Disconnect tonearm and disable it
	if gramophone and gramophone.tonearm:
		if gramophone.tonearm.stowed.is_connected(_on_tonearm_stowed):
			gramophone.tonearm.stowed.disconnect(_on_tonearm_stowed)
		gramophone.tonearm.set_interactable(false)
	
	# Stop playback (safety)
	if gramophone:
		gramophone.stop_playback()

func _process(delta: float):
	if _is_spinning and _current_vinyl:
		var target_node = _current_vinyl.snap_pivot if _current_vinyl.snap_pivot else _current_vinyl
		target_node.rotate_y(_spin_speed * TAU * delta)

func _on_tonearm_stowed():
	print("Tonearm stowed - leaving Playing")
	# Outline back to assemble (green) for the next time we mount
	if gramophone and gramophone.tonearm:
		gramophone.tonearm.set_outline_color(GameColors.OUTLINE_ASSEMBLE)
	# Stop playback and go back to VinylSpinning (where brake becomes the active disassembly step)
	if gramophone:
		gramophone.stop_playback()
	goto("VinylSpinning")

