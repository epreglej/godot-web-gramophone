extends Node3D
class_name GramophoneTonearm

signal mounted
signal stashed

enum Expectation { NONE, MOUNT, STASH }
var expectation := Expectation.NONE

@export var highlight: MeshInstance3D
@export var interactable_hinge: XRToolsInteractableHinge
@export var interactable_handle: XRToolsInteractableHandle
@export var lid: Lid

var following := true


func _ready():
	interactable_hinge.hinge_moved.connect(_on_hinge_moved)
	reset()


func reset():
	expectation = Expectation.NONE
	_set_active(false)
	following = true


func _physics_process(_delta):
	if following:
		global_transform = lid.tonearm_origin.global_transform


func expect_mount():
	expectation = Expectation.MOUNT
	following = false
	_set_active(true)


func expect_stash():
	expectation = Expectation.STASH
	_set_active(true)


func _set_active(value: bool):
	interactable_handle.enabled = value
	highlight.visible = value


func _on_hinge_moved(angle: float):
	match expectation:
		Expectation.MOUNT:
			if angle <= -55.0:
				reset()
				mounted.emit()

		Expectation.STASH:
			if angle >= 0.0:
				reset()
				following = true
				stashed.emit()
