extends GameState

## Intro state - waiting for user to click "Comenzar"

func enter_state():
	print("Entered: Intro")
	
	# Disable all interactions first
	if gramophone:
		gramophone.disable_all_interactables()
		gramophone.set_instructions("Presiona 'Comenzar' para empezar")
