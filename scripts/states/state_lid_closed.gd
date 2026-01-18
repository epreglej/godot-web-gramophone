extends GameState

## Lid Closed state - user needs to open the lid

func enter_state():
	print("Entered: LidClosed")
	
	# Enable lid interaction and show outline
	if gramophone and gramophone.lid:
		gramophone.lid.set_interactable(true)
		gramophone.lid.opened.connect(_on_lid_opened)
	
	if gramophone:
		gramophone.set_instructions("[color=green]Abre la tapa[/color]")

func exit_state():
	# Disconnect signal
	if gramophone and gramophone.lid:
		if gramophone.lid.opened.is_connected(_on_lid_opened):
			gramophone.lid.opened.disconnect(_on_lid_opened)

func _on_lid_opened():
	if gramophone and gramophone.lid:
		await gramophone.lid.play_animation("Opening")
	goto("LidOpen")
