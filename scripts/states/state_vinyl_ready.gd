extends GameState

## Vinyl ready - user can select a vinyl to inspect

func enter_state():
	print("Entered: VinylReady")
	
	# Disable all interactions first
	if gramophone:
		gramophone.disable_all_interactables()
	
	# Enable filter pickable (to allow removal) - red = back
	if gramophone and gramophone.filter_pickable:
		gramophone.filter_pickable.set_outline_color(GameColors.OUTLINE_DISASSEMBLE)
		gramophone.filter_pickable.set_interactable(true)
		gramophone.filter_pickable.picked_up.connect(_on_filter_picked_up)
	
	# Enable all vinyls - green = forward
	if gramophone:
		for vinyl in gramophone.vinyls:
			if vinyl and not gramophone.mounted_vinyl:
				vinyl.set_outline_color(GameColors.OUTLINE_ASSEMBLE)
				vinyl.set_interactable(true)
				vinyl.inspection_started.connect(_on_vinyl_inspection_started)
	
	if gramophone:
		gramophone.set_instructions("[color=green]Selecciona un vinilo[/color]\n[color=red]O retira el filtro[/color]")

func exit_state():
	# Disable filter
	if gramophone and gramophone.filter_pickable:
		if gramophone.filter_pickable.picked_up.is_connected(_on_filter_picked_up):
			gramophone.filter_pickable.picked_up.disconnect(_on_filter_picked_up)
		gramophone.filter_pickable.set_interactable(false)
	
	# Disable all vinyls
	if gramophone:
		for vinyl in gramophone.vinyls:
			if vinyl:
				if vinyl.inspection_started.is_connected(_on_vinyl_inspection_started):
					vinyl.inspection_started.disconnect(_on_vinyl_inspection_started)
				vinyl.set_interactable(false)

func _on_filter_picked_up():
	# User picked up the filter to remove it
	goto("FilterPickedUp")

func _on_vinyl_inspection_started(vinyl: SimpleVinyl):
	# Store the inspecting vinyl and go to inspection state
	if gramophone:
		gramophone.inspecting_vinyl = vinyl
	goto("VinylInspecting")
