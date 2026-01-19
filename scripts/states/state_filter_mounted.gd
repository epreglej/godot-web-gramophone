extends GameState

## Filter mounted - filter is on the turntable

func enter_state():
	print("Entered: FilterMounted")
	
	# Disable all interactions first
	if gramophone:
		gramophone.disable_all_interactables()
	
	# Enable filter pickable (to allow removal) - red = back
	if gramophone and gramophone.filter_pickable:
		gramophone.filter_pickable.set_outline_color(GameColors.OUTLINE_DISASSEMBLE)
		gramophone.filter_pickable.set_interactable(true)
		gramophone.filter_pickable.picked_up.connect(_on_filter_picked_up)
	
	if gramophone:
		gramophone.set_instructions("[color=green]¡Filtro colocado![/color]\n[color=red]Puedes retirarlo[/color]")

func exit_state():
	if gramophone and gramophone.filter_pickable:
		if gramophone.filter_pickable.picked_up.is_connected(_on_filter_picked_up):
			gramophone.filter_pickable.picked_up.disconnect(_on_filter_picked_up)
		gramophone.filter_pickable.set_interactable(false)

func _on_filter_picked_up():
	# User picked up the filter to move it
	goto("FilterPickedUp")
