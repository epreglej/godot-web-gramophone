extends GameState

## Filter picked up - user is holding the filter, needs to place it on turntable

func enter_state():
	print("Entered: FilterPickedUp")
	
	# Disable all interactions first
	if gramophone:
		gramophone.disable_all_interactables()
	
	# Keep filter enabled so it can be picked up again if dropped
	if gramophone and gramophone.filter_pickable:
		gramophone.filter_pickable.set_outline_color(GameColors.OUTLINE_NEUTRAL)
		gramophone.filter_pickable.set_interactable(true)
	
	# Clear and enable mounted snap zone (turntable) - green = forward
	if gramophone and gramophone.mounted_filter_snap_zone:
		gramophone.mounted_filter_snap_zone.clear()
		gramophone.mounted_filter_snap_zone.set_highlight_color(GameColors.COLOR_ASSEMBLE)
		gramophone.mounted_filter_snap_zone.set_active(true)
		gramophone.mounted_filter_snap_zone.object_snapped.connect(_on_filter_mounted)
	
	# Clear and enable stashed snap zone (table) - red = back
	if gramophone and gramophone.stashed_filter_snap_zone:
		gramophone.stashed_filter_snap_zone.clear()
		gramophone.stashed_filter_snap_zone.set_highlight_color(GameColors.COLOR_DISASSEMBLE)
		gramophone.stashed_filter_snap_zone.set_active(true)
		gramophone.stashed_filter_snap_zone.object_snapped.connect(_on_filter_stashed)
	
	if gramophone:
		gramophone.set_instructions("Coloca el filtro en el plato", "Devuélvelo")

func exit_state():
	# Disable snap zones
	if gramophone and gramophone.mounted_filter_snap_zone:
		gramophone.mounted_filter_snap_zone.set_active(false)
		if gramophone.mounted_filter_snap_zone.object_snapped.is_connected(_on_filter_mounted):
			gramophone.mounted_filter_snap_zone.object_snapped.disconnect(_on_filter_mounted)
	
	if gramophone and gramophone.stashed_filter_snap_zone:
		gramophone.stashed_filter_snap_zone.set_active(false)
		if gramophone.stashed_filter_snap_zone.object_snapped.is_connected(_on_filter_stashed):
			gramophone.stashed_filter_snap_zone.object_snapped.disconnect(_on_filter_stashed)

func _on_filter_mounted(_object: Node3D):
	# Filter placed on turntable - go straight to vinyl selection
	goto("VinylReady")

func _on_filter_stashed(_object: Node3D):
	# User put filter back, return to filter ready state
	goto("FilterReady")
