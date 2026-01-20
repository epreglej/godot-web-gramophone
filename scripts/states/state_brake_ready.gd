extends GameState

## Brake ready - user can click brake to disengage and start vinyl spinning

var _current_vinyl: SimpleVinyl = null
var _vinyl_spinning: bool = false

func enter_state():
	print("Entered: BrakeReady")
	
	# Disable all interactions first
	if gramophone:
		gramophone.disable_all_interactables()
	
	_current_vinyl = gramophone.mounted_vinyl if gramophone else null
	if _current_vinyl:
		# Move vinyl to mounted position (above filter on turntable)
		if gramophone.mounted_vinyl_snap_zone:
			var snap_pos = gramophone.mounted_vinyl_snap_zone.global_position
			_current_vinyl.move_to_position(snap_pos, Basis.IDENTITY)
		# Enable vinyl for removal - red = back
		_current_vinyl.set_outline_color(GameColors.OUTLINE_DISASSEMBLE)
		_current_vinyl.set_interactable(true)
		_current_vinyl.inspection_started.connect(_on_vinyl_inspection_started)
	
	# Enable brake - green = forward (disengage to start)
	if gramophone and gramophone.brake:
		gramophone.brake.set_outline_color(GameColors.OUTLINE_ASSEMBLE)
		gramophone.brake.set_interactable(true)
		gramophone.brake.disengaged.connect(_on_brake_disengaged)
	
	if gramophone:
		var song = gramophone.selected_song
		var song_info = "%s - %s" % [song.artist, song.title] if song else "Desconocido"
		var assemble_text = "¡Vinilo colocado! %s\nDesactiva el freno para hacer girar el vinilo" % song_info
		var disassemble_text = "Toca el vinilo para cambiarlo"
		gramophone.set_instructions(assemble_text, disassemble_text)

func exit_state():
	if _current_vinyl:
		if _current_vinyl.inspection_started.is_connected(_on_vinyl_inspection_started):
			_current_vinyl.inspection_started.disconnect(_on_vinyl_inspection_started)
		_current_vinyl.set_interactable(false)
		_current_vinyl = null
	
	if gramophone and gramophone.brake:
		if gramophone.brake.disengaged.is_connected(_on_brake_disengaged):
			gramophone.brake.disengaged.disconnect(_on_brake_disengaged)
		gramophone.brake.set_interactable(false)

func _on_brake_disengaged():
	print("Brake disengaged - starting vinyl spin")
	_start_vinyl_spin()
	goto("VinylSpinning")

func _on_vinyl_inspection_started(vinyl: SimpleVinyl):
	# User wants to change/remove the vinyl
	if gramophone:
		gramophone.inspecting_vinyl = vinyl
	goto("VinylInspecting")

func _start_vinyl_spin():
	if _current_vinyl:
		# Start spinning the vinyl around Y axis
		_vinyl_spinning = true
		# The spinning will be handled in VinylSpinning state
