extends Node3D
class_name GramophoneBrake

signal disengaged
signal engaged

enum Expectation { NONE, ENGAGE, DISENGAGE }
var expectation := Expectation.NONE

@export var interactable_hinge: XRToolsInteractableHinge
@export var interactable_handle: XRToolsInteractableHandle
@export var highlight: MeshInstance3D


func _ready():
	interactable_hinge.hinge_moved.connect(_on_hinge_moved)
	reset()


func reset():
	expectation = Expectation.NONE
	_set_active(false)


func expect_disengage():
	expectation = Expectation.DISENGAGE
	_set_active(true)


func expect_engage():
	expectation = Expectation.ENGAGE
	_set_active(true)


func _set_active(value: bool):
	interactable_handle.enabled = value
	highlight.visible = value


func _on_hinge_moved(angle: float):
	match expectation:
		Expectation.DISENGAGE:
			if angle >= interactable_hinge.hinge_limit_max:
				reset()
				disengaged.emit()

		Expectation.ENGAGE:
			if angle <= interactable_hinge.hinge_limit_min:
				reset()
				engaged.emit()
