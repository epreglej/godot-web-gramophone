extends GameState

## Intro state - waiting for user to click "Comenzar"

func enter_state():
	print("Entered: Intro")
	
	# Disable all interactions and hide outlines
	if gramophone and gramophone.lid:
		gramophone.lid.set_interactable(false)
	
	if gramophone:
		gramophone.set_instructions("Presiona 'Comenzar' para empezar")
