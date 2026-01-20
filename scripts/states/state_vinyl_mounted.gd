extends GameState

## Vinyl mounted - vinyl is on the gramophone turntable

func enter_state():
	print("Entered: VinylMounted")
	
	# Disable all interactions first
	if gramophone:
		gramophone.disable_all_interactables()
	
	_current_vinyl = gramophone.mounted_vinyl if gramophone else null
	if _current_vinyl:
		var vinyl = _current_vinyl
		# Move vinyl to mounted position (above filter on turntable)
		if gramophone.mounted_vinyl_snap_zone:
			var snap_pos = gramophone.mounted_vinyl_snap_zone.global_position
			vinyl.move_to_position(snap_pos, Basis.IDENTITY)
		
		# Enable vinyl for removal - red = back
		vinyl.set_outline_color(GameColors.OUTLINE_DISASSEMBLE)
		vinyl.set_interactable(true)
		vinyl.inspection_started.connect(_on_vinyl_inspection_started)
	
	if gramophone:
		var song = gramophone.selected_song
		var song_info = "%s - %s" % [song.artist, song.title] if song else "Desconocido"
		gramophone.set_instructions("¡Vinilo colocado! %s" % song_info, "Toca para cambiar")
	
	# Auto-transition to BrakeReady
	goto("BrakeReady")

var _current_vinyl: SimpleVinyl = null  # Track locally to ensure cleanup

func exit_state():
	if _current_vinyl:
		if _current_vinyl.inspection_started.is_connected(_on_vinyl_inspection_started):
			_current_vinyl.inspection_started.disconnect(_on_vinyl_inspection_started)
		_current_vinyl.set_interactable(false)
		_current_vinyl = null

func _on_vinyl_inspection_started(vinyl: SimpleVinyl):
	# User wants to change/remove the vinyl
	if gramophone:
		gramophone.inspecting_vinyl = vinyl
		# Don't clear mounted_vinyl here - let VinylInspecting handle it
	goto("VinylInspecting")
