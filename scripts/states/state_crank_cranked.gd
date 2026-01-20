extends GameState

## Crank cranked - gramophone is wound up, proceed to filter

func enter_state():
	print("Entered: CrankCranked")
	
	# Disable all interactions first
	if gramophone:
		gramophone.disable_all_interactables()
		gramophone.set_instructions("¡Gramófono listo!")
	
	# Automatically proceed to filter step
	goto("FilterReady")

func exit_state():
	pass
