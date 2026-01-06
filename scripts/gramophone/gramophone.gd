extends Node
class_name Gramophone

@export var audio_player: AudioStreamPlayer3D
@export var instructions_label: Label3D
@export var state_label: Label3D

@export var lid: Lid
@export var filter_system: FilterSystem

@export var crank_pickable: CrankPickable
@export var mounted_crank_snap_zone: CrankSnapZone
@export var stashed_crank_snap_zone: CrankSnapZone

@export var vinyl_system: GramophoneVinylSystem
@export var brake: GramophoneBrake


enum State {
	LID_CLOSED,
	LID_OPEN,

	CRANK_PICKED_UP,
	CRANK_INSERTED,
	CRANK_CRANKED,

	FILTER_PICKED_UP,
	FILTER_MOUNTED,

	VINYL_PICKED_UP,
	VINYL_MOUNTED,
	TONEARM_MOUNTED,
	PLAYING
}

var state: State = State.LID_CLOSED
# TODO: Reset it to false after adding the cranking to the crank
var _is_cranked: bool = true


func _ready():
	crank_pickable.set_interactable(true)
	stashed_crank_snap_zone.set_active(true)
	stashed_crank_snap_zone.pick_up_object(crank_pickable)
	stashed_crank_snap_zone.set_active(false)
	crank_pickable.set_interactable(false)
	
	lid.opened.connect(_on_lid_opened)
	lid.closed.connect(_on_lid_closed)
	
	mounted_crank_snap_zone.has_dropped.connect(_on_crank_picked_up)
	stashed_crank_snap_zone.has_dropped.connect(_on_crank_picked_up)
	mounted_crank_snap_zone.has_picked_up.connect(_on_crank_inserted)
	stashed_crank_snap_zone.has_picked_up.connect(_on_crank_stashed)
	
	filter_system.picked_up.connect(_on_filter_picked_up)
	filter_system.mounted.connect(_on_filter_mounted)
	filter_system.stashed.connect(_on_filter_stashed)
	
	vinyl_system.vinyl_picked_up.connect(_on_vinyl_picked_up)
	vinyl_system.vinyl_mounted.connect(_on_vinyl_mounted)
	vinyl_system.vinyl_stashed.connect(_on_vinyl_stashed)
	
	lid.tonearm.mounted.connect(_on_tonearm_mounted)
	lid.tonearm.stashed.connect(_on_tonearm_stashed)
	
	#brake.disengaged.connect(_on_brake_disengaged)
	#brake.engaged.connect(_on_brake_engaged)
	
	# await _warmup_all_vinyls()
	_refresh_permissions()
	
	#_on_lid_opened()
	#_on_crank_picked_up()
	#_on_crank_inserted()


func _physics_process(_delta: float) -> void:
	pass
	#if vinyl_system.mounted_vinyl and state == State.PLAYING:
		#vinyl_system.mounted_vinyl.get_node("Model").rotate_y(deg_to_rad(1))


func _refresh_permissions():
	lid.set_active(false)
	
	crank_pickable.set_interactable(false)
	mounted_crank_snap_zone.set_active(false)
	stashed_crank_snap_zone.set_active(false)
	
	filter_system.set_active(false)
	vinyl_system.reset()
	lid.tonearm.reset()
	#brake.reset()
	
	match state:
		State.LID_CLOSED:
			state_label.text = "LID_CLOSED"
			instructions_label.text = "Open the lid"
			
			lid.set_active(true)
			lid.set_outline_shader_params(Color(1,1,0,0.3), 1)
		
		State.LID_OPEN:
			state_label.text = "LID_OPEN"
			instructions_label.text = "Pick up the crank \n - OR - \n Close the lid"
			
			crank_pickable.set_interactable(true)
			mounted_crank_snap_zone.set_active(true)
			mounted_crank_snap_zone.set_highlight_visible(false)
			stashed_crank_snap_zone.set_active(true)
			stashed_crank_snap_zone.set_highlight_visible(false)
			
			lid.set_active(true)
			lid.set_outline_shader_params(Color(1,0.4,0,0.3), 1)
		
		State.CRANK_PICKED_UP:
			state_label.text = "CRANK_PICKED_UP"
			instructions_label.text = "Insert the crank \n - OR - \n Stash the crank"
			
			crank_pickable.set_interactable(true)
			mounted_crank_snap_zone.set_active(true)
			stashed_crank_snap_zone.set_active(true)
		
		State.CRANK_INSERTED:
			state_label.text = "CRANK_INSERTED"
			if _is_cranked:
				_on_crank_cranked()
			else:
				instructions_label.text = "Crank the crank"
				#crank_system.expect_cranking()

		State.CRANK_CRANKED:
			state_label.text = "CRANK_CRANKED"
			instructions_label.text = "Pick up the filter \n - OR - \n Pick up the crank to stash it"
			
			filter_system.set_active(true)
			filter_system.show_pickup_hint(Color(1, 0.7, 0))
			
			crank_pickable.set_interactable(true)
			mounted_crank_snap_zone.set_active(true)
			mounted_crank_snap_zone.set_highlight_visible(false)
			stashed_crank_snap_zone.set_active(true)
			stashed_crank_snap_zone.set_highlight_visible(false)

		State.FILTER_PICKED_UP:
			instructions_label.text = "Mount the filter \n - OR - \n Stash the filter"
			filter_system.set_active(true)

		State.FILTER_MOUNTED:
			instructions_label.text = "Pick up any vinyl \n - OR - \n Pick up the filter to stash it"
			vinyl_system.expect_pick_up()
			filter_system.set_active(true)

		State.VINYL_PICKED_UP:
			instructions_label.text = "Mount or stash the picked up vinyl"
			vinyl_system.expect_mount_or_stash()

		State.VINYL_MOUNTED:
			instructions_label.text = "Mount the tonearm \n - OR - \n Remove the vinyl"
			lid.tonearm.expect_mount()
			vinyl_system.expect_pick_up()
		
		State.TONEARM_MOUNTED:
			instructions_label.text = "Disengage the brake to play \n - OR - \n Stash the tonearm"
			brake.expect_disengage()
			lid.tonearm.expect_stash()
		
		State.PLAYING:
			instructions_label.text = "Engage the brake to stop playing"
			brake.expect_engage()


# CALLBACKS

func _on_lid_opened():
	if state != State.LID_CLOSED:
		return
	
	lid.play_animation("Opening")
	
	state = State.LID_OPEN
	_refresh_permissions()


func _on_lid_closed():
	if state != State.LID_OPEN:
		return
	
	lid.play_animation("Closing")
	
	state = State.LID_CLOSED
	_refresh_permissions()


func _on_crank_picked_up():
	if state != State.LID_OPEN and state != State.CRANK_CRANKED:
		return
	
	state = State.CRANK_PICKED_UP
	_refresh_permissions()

func _on_crank_inserted(_what: Variant):
	#if state != State.CRANK_PICKED_UP:
		#return
	
	state = State.CRANK_INSERTED
	_refresh_permissions()

func _on_crank_cranked():
	# Maybe there shouldn't be a checker here because
	# it should be possible to creank the crank when
	# it finally unwinds
	
	state = State.CRANK_CRANKED
	_refresh_permissions()

func _on_crank_stashed(_what: Variant):
	#if state != State.CRANK_PICKED_UP:
		#return
	
	#_is_cranked = false
	
	state = State.LID_OPEN
	_refresh_permissions()


# FILTER

func _on_filter_picked_up():
	#if state != State.CRANK_CRANKED and state != State.FILTER_MOUNTED:
		#return
	
	state = State.FILTER_PICKED_UP
	_refresh_permissions()


func _on_filter_mounted():
	if state != State.FILTER_PICKED_UP:
		return
	
	state = State.FILTER_MOUNTED
	_refresh_permissions()


func _on_filter_stashed():
	if state != State.FILTER_PICKED_UP:
		return
	
	state = State.CRANK_CRANKED
	_refresh_permissions()


# VINYL

func _on_vinyl_picked_up():
	state = State.VINYL_PICKED_UP
	_refresh_permissions()

func _on_vinyl_mounted():
	state = State.VINYL_MOUNTED
	_refresh_permissions()

func _on_vinyl_stashed():
	state = State.FILTER_MOUNTED
	_refresh_permissions()


# --- TONEARM ---

func _on_tonearm_mounted():
	state = State.TONEARM_MOUNTED
	_refresh_permissions()

func _on_tonearm_stashed():
	state = State.VINYL_MOUNTED
	_refresh_permissions()


# --- BRAKE / AUDIO ---

func _on_brake_disengaged():
	state = State.PLAYING

	if audio_player.stream and audio_player.stream.resource_path == vinyl_system.mounted_vinyl.song.resource_path:
		audio_player.stream_paused = false
	else:
		audio_player.stream = vinyl_system.mounted_vinyl.song.audio_stream
		audio_player.play()

	_refresh_permissions()

func _on_brake_engaged():
	state = State.TONEARM_MOUNTED
	audio_player.stream_paused = true
	_refresh_permissions()


# AUDIO WARMUP

func _warmup_all_vinyls() -> void:
	for vinyl in vinyl_system.vinyls:
		if vinyl == null:
			continue

		var streams: Array[AudioStream] = [
			vinyl._song_a.audio_stream,
			vinyl._song_b.audio_stream
		]

		for stream in streams:
			if stream == null:
				continue

			audio_player.stream = stream
			audio_player.volume_db = -80
			audio_player.play()

			await get_tree().process_frame
			await get_tree().process_frame

			audio_player.stop()

	audio_player.stream = null
	audio_player.volume_db = 0
