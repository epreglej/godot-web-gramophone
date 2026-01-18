extends GameState

## Crank picked up - user is holding the crank, needs to insert it

func enter_state():
	print("Entered: CrankPickedUp")
	
	# Disable lid while holding crank
	if gramophone and gramophone.lid:
		gramophone.lid.set_interactable(false)
	
	# Keep crank enabled so it can be picked up again if dropped outside snap zones
	if gramophone and gramophone.crank_pickable:
		gramophone.crank_pickable.set_interactable(true)
	
	# Clear and enable mounted snap zone
	if gramophone and gramophone.mounted_crank_snap_zone:
		gramophone.mounted_crank_snap_zone.clear()  # Clear any previous reference
		gramophone.mounted_crank_snap_zone.set_active(true)
		gramophone.mounted_crank_snap_zone.object_snapped.connect(_on_crank_inserted)
	
	# Clear and enable stashed snap zone (to put it back)
	if gramophone and gramophone.stashed_crank_snap_zone:
		gramophone.stashed_crank_snap_zone.clear()  # Clear any previous reference
		gramophone.stashed_crank_snap_zone.set_active(true)
		gramophone.stashed_crank_snap_zone.object_snapped.connect(_on_crank_stashed)
	
	if gramophone:
		gramophone.set_instructions("[color=green]Inserta la manivela[/color]\no guárdala de nuevo")

func exit_state():
	if gramophone and gramophone.mounted_crank_snap_zone:
		if gramophone.mounted_crank_snap_zone.object_snapped.is_connected(_on_crank_inserted):
			gramophone.mounted_crank_snap_zone.object_snapped.disconnect(_on_crank_inserted)
	
	if gramophone and gramophone.stashed_crank_snap_zone:
		if gramophone.stashed_crank_snap_zone.object_snapped.is_connected(_on_crank_stashed):
			gramophone.stashed_crank_snap_zone.object_snapped.disconnect(_on_crank_stashed)

func _on_crank_inserted(_object: Node3D):
	goto("CrankInserted")

func _on_crank_stashed(_object: Node3D):
	# User put crank back, go back to lid open state
	goto("LidOpen")
