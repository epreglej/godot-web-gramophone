extends GameState

## Crank cranking - click the crank to wind up the gramophone

var _is_cranking: bool = false
var _animation_player: AnimationPlayer = null

func enter_state():
	print("Entered: CrankCranking")
	_is_cranking = false
	
	# Disable all interactions first
	if gramophone:
		gramophone.disable_all_interactables()
	
	# Get the animation player from the crank
	if gramophone and gramophone.crank_pickable:
		_animation_player = gramophone.crank_pickable.get_node_or_null("AnimationPlayer")
		if _animation_player:
			_animation_player.animation_finished.connect(_on_animation_finished)
	
	# Enable crank pickable for clicking (but we'll intercept the grab)
	if gramophone and gramophone.crank_pickable:
		gramophone.crank_pickable.set_outline_color(GameColors.OUTLINE_ASSEMBLE)
		gramophone.crank_pickable.set_interactable(true)
		gramophone.crank_pickable.picked_up.connect(_on_crank_clicked)
	
	if gramophone:
		gramophone.set_instructions("Haz clic en la manivela para dar cuerda")

func exit_state():
	if gramophone and gramophone.crank_pickable:
		if gramophone.crank_pickable.picked_up.is_connected(_on_crank_clicked):
			gramophone.crank_pickable.picked_up.disconnect(_on_crank_clicked)
	
	if _animation_player:
		if _animation_player.animation_finished.is_connected(_on_animation_finished):
			_animation_player.animation_finished.disconnect(_on_animation_finished)
		_animation_player = null

func _on_crank_clicked():
	if _is_cranking:
		return
	
	_is_cranking = true
	
	# Immediately release the crank (we don't want to pick it up, just click it)
	if gramophone and gramophone.crank_pickable:
		gramophone.crank_pickable.on_release()
		gramophone.crank_pickable.set_interactable(false)
		
		# Play the cranking animation
		if _animation_player:
			_animation_player.play("Cranking")

func _on_animation_finished(anim_name: String):
	if anim_name == "Cranking":
		_on_cranking_complete()

func _on_cranking_complete():
	# Reset crank rotation for future use
	if _animation_player:
		_animation_player.play("RESET")
	
	# Crank is done; go directly to filter step
	goto("FilterReady")
