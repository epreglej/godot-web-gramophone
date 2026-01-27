extends GameState

## Filter ready - crank is done, user can pick up the filter OR remove crank to go back

func enter_state():
	print("Entered: FilterReady")
	
	# Disable all interactions first
	if gramophone:
		gramophone.disable_all_interactables()
	
	# Enable crank (to allow removal/going back) - red = back
	if gramophone and gramophone.crank:
		gramophone.crank.set_outline_color(GameColors.OUTLINE_DISASSEMBLE)
		gramophone.crank.set_interactable(true)
		gramophone.crank.picked_up.connect(_on_crank_picked_up)
	
	# Enable filter pickable - green = forward
	if gramophone and gramophone.filter_pickable:
		gramophone.filter_pickable.set_outline_color(GameColors.OUTLINE_ASSEMBLE)
		gramophone.filter_pickable.set_interactable(true)
		gramophone.filter_pickable.picked_up.connect(_on_filter_picked_up)
	
	if gramophone:
		gramophone.set_instructions("Coge el filtro", "Retira la manivela")

func exit_state():
	if gramophone and gramophone.crank:
		if gramophone.crank.picked_up.is_connected(_on_crank_picked_up):
			gramophone.crank.picked_up.disconnect(_on_crank_picked_up)
		gramophone.crank.set_interactable(false)
	
	if gramophone and gramophone.filter_pickable:
		if gramophone.filter_pickable.picked_up.is_connected(_on_filter_picked_up):
			gramophone.filter_pickable.picked_up.disconnect(_on_filter_picked_up)
		gramophone.filter_pickable.set_interactable(false)

func _on_filter_picked_up():
	goto("FilterPickedUp")

func _on_crank_picked_up():
	# User wants to remove crank - go back to CrankPickedUp
	goto("CrankPickedUp")
