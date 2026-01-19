extends GameState

## Crank inserted - crank is in the gramophone slot, transition to cranking

func enter_state():
	print("Entered: CrankInserted")
	
	# Disable all interactions first
	if gramophone:
		gramophone.disable_all_interactables()
		gramophone.set_instructions("[color=green]¡Manivela insertada![/color]")
	
	# Automatically transition to cranking state
	goto("CrankCranking")

func exit_state():
	pass
