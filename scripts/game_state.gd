extends Node
class_name GameState

## Base class for game states
## Override enter_state() and exit_state() in child classes

# Reference to parent state machine (set automatically)
var state_machine: StateMachine = null

# References to game objects (set by gramophone)
var gramophone: Node3D = null

func _ready():
	state_machine = get_parent() as StateMachine

## Called when entering this state
func enter_state():
	pass

## Called when exiting this state
func exit_state():
	pass

## Helper to change to another state
func goto(state_name: String):
	if state_machine:
		state_machine.change_state(state_name)
