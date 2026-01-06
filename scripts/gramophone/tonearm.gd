extends Node3D
class_name Tonearm

signal mounted
signal stashed

enum Expectation { NONE, MOUNT, STASH }
var expectation := Expectation.NONE

@export var outline: MeshInstance3D
@export var interactable_hinge: XRToolsInteractableHinge
@export var interactable_handle: XRToolsInteractableHandle


func _ready():
	interactable_hinge.hinge_moved.connect(_on_hinge_moved)
	reset()


func reset():
	expectation = Expectation.NONE
	set_interactable(false)


func expect_mount():
	expectation = Expectation.MOUNT
	set_interactable(true)


func expect_stash():
	expectation = Expectation.STASH
	set_interactable(true)


func set_interactable(value: bool):
	interactable_handle.enabled = value
	outline.visible = value


func _on_hinge_moved(angle: float):
	match expectation:
		Expectation.MOUNT:
			if angle <= -55.0:
				reset()
				mounted.emit()

		Expectation.STASH:
			if angle >= 0.0:
				reset()
				stashed.emit()
