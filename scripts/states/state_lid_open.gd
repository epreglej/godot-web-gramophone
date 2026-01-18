extends GameState

## Lid Open state - lid is open, user can pick up crank or close lid

func enter_state():
	print("Entered: LidOpen")
	
	# Enable lid (to allow closing)
	if gramophone and gramophone.lid:
		gramophone.lid.set_interactable(true)
		gramophone.lid.closed.connect(_on_lid_closed)
	
	# Enable crank pickup
	if gramophone and gramophone.crank_pickable:
		gramophone.crank_pickable.set_interactable(true)
		gramophone.crank_pickable.picked_up.connect(_on_crank_picked_up)
	
	if gramophone:
		gramophone.set_instructions("[color=green]Coge la manivela[/color]\no cierra la tapa")

func exit_state():
	if gramophone and gramophone.lid:
		if gramophone.lid.closed.is_connected(_on_lid_closed):
			gramophone.lid.closed.disconnect(_on_lid_closed)
		gramophone.lid.set_interactable(false)
	
	if gramophone and gramophone.crank_pickable:
		if gramophone.crank_pickable.picked_up.is_connected(_on_crank_picked_up):
			gramophone.crank_pickable.picked_up.disconnect(_on_crank_picked_up)
		gramophone.crank_pickable.set_interactable(false)

func _on_crank_picked_up():
	goto("CrankPickedUp")

func _on_lid_closed():
	# Play closing animation then go to LidClosed
	if gramophone and gramophone.lid:
		await gramophone.lid.play_animation("Closing")
	goto("LidClosed")
