extends Node
class_name StateMachine

## Simple state machine where each child node represents a state
## States are Node children with optional enter/exit methods

signal state_changed(old_state: String, new_state: String)

@export var initial_state: String = ""
@export var debug: bool = true

var current_state: Node = null
var current_state_name: String = ""

func _ready():
	# Wait one frame for children to be ready
	await get_tree().process_frame
	
	if initial_state != "":
		change_state(initial_state)

func change_state(new_state_name: String) -> bool:
	# Find the state node
	var new_state = get_node_or_null(new_state_name)
	if not new_state:
		if debug:
			push_error("StateMachine: State not found: " + new_state_name)
		return false
	
	var old_state_name = current_state_name
	
	# Exit current state
	if current_state and current_state.has_method("exit_state"):
		current_state.exit_state()
	
	# Enter new state
	current_state = new_state
	current_state_name = new_state_name
	
	if current_state.has_method("enter_state"):
		current_state.enter_state()
	
	if debug:
		print("StateMachine: ", old_state_name, " -> ", new_state_name)
	
	state_changed.emit(old_state_name, new_state_name)
	return true

func get_current_state_name() -> String:
	return current_state_name

func get_current_state() -> Node:
	return current_state

func is_in_state(state_name: String) -> bool:
	return current_state_name == state_name
