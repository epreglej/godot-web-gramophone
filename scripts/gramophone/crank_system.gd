extends Node3D
class_name CrankSystem

signal crank_inserted
signal crank_stashed
signal crank_cranked
signal crank_picked_up


enum Expectation { NONE, PICK_UP, INSERT_OR_STASH, CRANK }
var expectation: Expectation = Expectation.NONE


@export var gramophone_crank_pickable: CrankPickable
@export var inserted_crank_snap_zone: CrankSnapZone
@export var stashed_crank_snap_zone: CrankSnapZone


func _ready() -> void:
	# Start with crank stashed
	gramophone_crank_pickable.set_interactable(true)
	stashed_crank_snap_zone.set_active(true)
	stashed_crank_snap_zone.pick_up_object(gramophone_crank_pickable)
	stashed_crank_snap_zone.set_active(false)
	gramophone_crank_pickable.set_interactable(false)
	
	inserted_crank_snap_zone.has_picked_up.connect(_on_inserted_snap_zone_has_picked_up)
	stashed_crank_snap_zone.has_picked_up.connect(_on_stashed_snap_zone_has_picked_up)
	
	inserted_crank_snap_zone.has_dropped.connect(_on_snap_zone_has_dropped)
	stashed_crank_snap_zone.has_dropped.connect(_on_snap_zone_has_dropped)
	
	#if gramophone_crank and gramophone_crank.interactable_hinge:
		#gramophone_crank.interactable_hinge.hinge_moved.connect(_on_hinge_moved)
	
	#reset()


func expect_none() -> void:
	expectation = Expectation.NONE
	
	gramophone_crank_pickable.set_interactable(false)
	inserted_crank_snap_zone.activated = false
	stashed_crank_snap_zone.activated = false


func expect_pick_up() -> void:
	expectation = Expectation.PICK_UP

	gramophone_crank_pickable.set_interactable(true)

	# Only enable the snap zone that currently holds the crank
	if inserted_crank_snap_zone.picked_up_object:
		inserted_crank_snap_zone.activated = true
		inserted_crank_snap_zone.set_highlight_color(Color(1, 0.7, 0))
		gramophone_crank_pickable.set_highlight_color(Color(1,0,0), 1.0)
	elif stashed_crank_snap_zone.picked_up_object:
		stashed_crank_snap_zone.activated = true
		stashed_crank_snap_zone.set_highlight_color(Color(0, 1, 0))
		gramophone_crank_pickable.set_highlight_color(Color(0,1,0), 2.0)


func expect_insert_or_stash() -> void:
	expectation = Expectation.INSERT_OR_STASH
	
	gramophone_crank_pickable.set_interactable(true)
	
	inserted_crank_snap_zone.set_highlight_color(Color(0, 1, 0))
	inserted_crank_snap_zone.activated = true
	stashed_crank_snap_zone.set_highlight_color(Color(1, 0.7, 0))
	stashed_crank_snap_zone.activated = true


func expect_cranking() -> void:
	expectation = Expectation.CRANK
	
	#gramophone_crank.set_highlight_crank_color(Color(0, 1, 0))
	#_set_active(value)
	expect_none()
	crank_cranked.emit()


func _set_active(value: bool) -> void:
	match expectation:
		Expectation.INSERT_OR_STASH:
			inserted_crank_snap_zone.activated = value
			stashed_crank_snap_zone.activated = value
			gramophone_crank_pickable.set_interactable(value)
			#gramophone_crank.set_crankable(false)
			#gramophone_crank.highlight_grab.visible = true

		#Expectation.CRANK:
			#inserted_crank_snap_zone.activated = false
			#stashed_crank_snap_zone.activated = false
			#gramophone_crank.set_grabbable(false)
			#gramophone_crank.set_crankable(value)

		Expectation.PICK_UP:
			gramophone_crank_pickable.set_interactable(value)
			inserted_crank_snap_zone.activated = value
			stashed_crank_snap_zone.activated = value
			#gramophone_crank.set_crankable(false)

		Expectation.NONE:
			inserted_crank_snap_zone.activated = false
			stashed_crank_snap_zone.activated = false
			gramophone_crank_pickable.set_interactable(false)
			#gramophone_crank.set_crankable(false)
			#gramophone_crank.highlight_grab.visible = false


func _on_inserted_snap_zone_has_picked_up(_what: Variant) -> void:
	if expectation != Expectation.INSERT_OR_STASH:
		return
	expect_none()
	crank_inserted.emit()


func _on_stashed_snap_zone_has_picked_up(_what: Variant) -> void:
	if expectation != Expectation.INSERT_OR_STASH:
		return
	expect_none()
	crank_stashed.emit()


func _on_snap_zone_has_dropped() -> void:
	if expectation != Expectation.PICK_UP:
		return
	
	if inserted_crank_snap_zone.picked_up_object == null \
	and stashed_crank_snap_zone.picked_up_object == null:
		expect_none()
		crank_picked_up.emit()


func _on_hinge_moved(angle: float) -> void:
	if expectation == Expectation.CRANK and angle <= -900.0:
		expect_none()
		crank_cranked.emit()
