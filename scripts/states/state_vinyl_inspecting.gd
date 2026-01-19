extends GameState

## Vinyl inspecting - vinyl is shown close to camera, user can flip/select/cancel

var _came_from_mounted: bool = false  # Track if we're changing an already mounted vinyl

func enter_state():
	print("Entered: VinylInspecting")
	
	# Check if we came from VinylMounted (changing vinyl)
	_came_from_mounted = gramophone.mounted_vinyl != null if gramophone else false
	
	# Disable all interactions first
	if gramophone:
		gramophone.disable_all_interactables()
	
	var vinyl = gramophone.inspecting_vinyl if gramophone else null
	if not vinyl:
		print("ERROR: No inspecting vinyl!")
		goto("VinylReady")
		return
	
	# Move vinyl to inspection position
	if gramophone and gramophone.camera:
		vinyl.move_to_inspect_position(gramophone.camera)
	
	# Connect vinyl signals
	vinyl.side_selected.connect(_on_vinyl_selected)
	vinyl.cancelled.connect(_on_vinyl_cancelled)
	
	# Show vinyl inspection UI
	if gramophone and gramophone.ui:
		gramophone.ui.show_vinyl_inspection(vinyl)
	
	_update_instructions()

func exit_state():
	var vinyl = gramophone.inspecting_vinyl if gramophone else null
	if vinyl:
		if vinyl.side_selected.is_connected(_on_vinyl_selected):
			vinyl.side_selected.disconnect(_on_vinyl_selected)
		if vinyl.cancelled.is_connected(_on_vinyl_cancelled):
			vinyl.cancelled.disconnect(_on_vinyl_cancelled)
	
	# Hide vinyl inspection UI
	if gramophone and gramophone.ui:
		gramophone.ui.hide_vinyl_inspection()

func _update_instructions():
	if gramophone:
		gramophone.set_instructions("Usa los botones para [color=#66dd66]Girar[/color], [color=#66dd66]Elegir[/color] o [color=#dd6666]Dejar[/color] el vinilo")

func _on_vinyl_selected(vinyl: SimpleVinyl, song: Song):
	print("Vinyl selected: ", vinyl.name, " - Song: ", song.title if song else "none")
	if gramophone:
		gramophone.selected_song = song
		gramophone.mounted_vinyl = vinyl
	goto("VinylMounted")

func _on_vinyl_cancelled(vinyl: SimpleVinyl):
	print("Vinyl inspection cancelled, came_from_mounted: ", _came_from_mounted)
	if gramophone:
		gramophone.inspecting_vinyl = null
		
		# If we came from mounted, clear the mounted vinyl (unmount it)
		if _came_from_mounted:
			gramophone.mounted_vinyl = null
			gramophone.selected_song = null
	
	# Always go back to VinylReady - vinyl returns to its original position
	# (cancel_inspection() handles the animation back to _original_transform)
	goto("VinylReady")

# Called from UI buttons
func flip_vinyl():
	var vinyl = gramophone.inspecting_vinyl if gramophone else null
	if vinyl:
		vinyl.flip()
		# Update UI after flip animation
		var tween = create_tween()
		tween.tween_interval(0.35)
		tween.tween_callback(func():
			_update_instructions()
			if gramophone and gramophone.ui:
				gramophone.ui.update_vinyl_display(vinyl)
		)

func select_vinyl():
	var vinyl = gramophone.inspecting_vinyl if gramophone else null
	if vinyl:
		vinyl.select_current_side()

func cancel_inspection():
	var vinyl = gramophone.inspecting_vinyl if gramophone else null
	if vinyl:
		vinyl.cancel_inspection()
