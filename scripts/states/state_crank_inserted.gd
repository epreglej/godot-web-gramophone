extends GameState

## Crank inserted - crank is in the gramophone slot, can be removed

func enter_state():
	print("Entered: CrankInserted")
	
	# Disable lid while crank is inserted
	if gramophone and gramophone.lid:
		gramophone.lid.set_interactable(false)
	
	# Enable crank pickable (to allow removal)
	if gramophone and gramophone.crank_pickable:
		gramophone.crank_pickable.set_interactable(true)
		gramophone.crank_pickable.picked_up.connect(_on_crank_picked_up)
	
	# Disable snap zones (no need to snap when already inserted)
	if gramophone and gramophone.mounted_crank_snap_zone:
		gramophone.mounted_crank_snap_zone.set_active(false)
	if gramophone and gramophone.stashed_crank_snap_zone:
		gramophone.stashed_crank_snap_zone.set_active(false)
	
	if gramophone:
		gramophone.set_instructions("[color=green]¡Manivela insertada![/color]\nPuedes retirarla")

func exit_state():
	if gramophone and gramophone.crank_pickable:
		if gramophone.crank_pickable.picked_up.is_connected(_on_crank_picked_up):
			gramophone.crank_pickable.picked_up.disconnect(_on_crank_picked_up)
		gramophone.crank_pickable.set_interactable(false)

func _on_crank_picked_up():
	# User picked up the crank from mounted position
	goto("CrankPickedUp")
