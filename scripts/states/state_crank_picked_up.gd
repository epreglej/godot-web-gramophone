extends GameState

## Crank picked up - user is holding the crank, needs to insert it

func enter_state():
	print("Entered: CrankPickedUp")
	
	# Disable all interactions first
	if gramophone:
		gramophone.disable_all_interactables()
	
	# Crank uses neutral color when held (will show when dropped outside zones)
	if gramophone and gramophone.crank_pickable:
		gramophone.crank_pickable.set_outline_color(GameColors.OUTLINE_NEUTRAL)
		gramophone.crank_pickable.set_interactable(true)
	
	# Clear and enable mounted snap zone - green = assemble/forward
	if gramophone and gramophone.mounted_crank_snap_zone:
		gramophone.mounted_crank_snap_zone.clear()
		gramophone.mounted_crank_snap_zone.set_highlight_color(GameColors.COLOR_ASSEMBLE)
		gramophone.mounted_crank_snap_zone.set_active(true)
		gramophone.mounted_crank_snap_zone.object_snapped.connect(_on_crank_inserted)
	
	# Clear and enable stashed snap zone - red = disassemble/back
	if gramophone and gramophone.stashed_crank_snap_zone:
		gramophone.stashed_crank_snap_zone.clear()
		gramophone.stashed_crank_snap_zone.set_highlight_color(GameColors.COLOR_DISASSEMBLE)
		gramophone.stashed_crank_snap_zone.set_active(true)
		gramophone.stashed_crank_snap_zone.object_snapped.connect(_on_crank_stashed)
	
	if gramophone:
		gramophone.set_instructions("[color=green]Inserta la manivela[/color]\no [color=red]guárdala de nuevo[/color]")

func exit_state():
	# Disable snap zones and hide their highlights
	if gramophone and gramophone.mounted_crank_snap_zone:
		gramophone.mounted_crank_snap_zone.set_active(false)
		if gramophone.mounted_crank_snap_zone.object_snapped.is_connected(_on_crank_inserted):
			gramophone.mounted_crank_snap_zone.object_snapped.disconnect(_on_crank_inserted)
	
	if gramophone and gramophone.stashed_crank_snap_zone:
		gramophone.stashed_crank_snap_zone.set_active(false)
		if gramophone.stashed_crank_snap_zone.object_snapped.is_connected(_on_crank_stashed):
			gramophone.stashed_crank_snap_zone.object_snapped.disconnect(_on_crank_stashed)

func _on_crank_inserted(_object: Node3D):
	goto("CrankInserted")

func _on_crank_stashed(_object: Node3D):
	# User put crank back, go back to lid open state
	goto("LidOpen")
