extends GameState

## Filter mounted - filter is on the turntable, auto-transition to VinylReady

func enter_state():
	print("Entered: FilterMounted")
	
	# Disable all interactions first
	if gramophone:
		gramophone.disable_all_interactables()
	
	if gramophone:
		gramophone.set_instructions("[color=green]¡Filtro colocado![/color]")
	
	# Auto-transition to VinylReady after a brief moment
	var tween = create_tween()
	tween.tween_interval(0.5)
	tween.tween_callback(func(): goto("VinylReady"))

func exit_state():
	pass
