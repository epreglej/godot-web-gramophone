extends Node
class_name Gramophone

@export var audio_player: AudioStreamPlayer3D
@export var instructions_label: Label3D
@export var state_label: Label3D

@export var lid: Lid
@export var filter_system: FilterSystem

@export var crank_pickable: CrankPickable
@export var crank_crankable: CrankCrankable
@export var mounted_crank_snap_zone: CrankSnapZone
@export var stashed_crank_snap_zone: CrankSnapZone

@export var mounted_vinyl_snap_zone: VinylSnapZone
@export var vinyl_cole_porter: Vinyl
@export var stashed_vinyl_snap_zone_cole_porter: VinylSnapZone

@export var brake: Brake


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
var mounted_vinyl: Vinyl = null

# TODO: Reset it to false after adding the cranking to the crank
var _is_cranked: bool = false


func _ready():
	crank_crankable.set_visible(false)
	
	crank_pickable.set_interactable(true)
	stashed_crank_snap_zone.set_active(true)
	stashed_crank_snap_zone.pick_up_object(crank_pickable)
	stashed_crank_snap_zone.set_active(false)
	crank_pickable.set_interactable(false)
	
	#TODO: Repeat for all vinyls
	vinyl_cole_porter.set_interactable(true)
	stashed_vinyl_snap_zone_cole_porter.set_active(true)
	stashed_vinyl_snap_zone_cole_porter.pick_up_object(vinyl_cole_porter)
	stashed_vinyl_snap_zone_cole_porter.set_active(false)
	vinyl_cole_porter.set_interactable(false)
	
	lid.opened.connect(_on_lid_opened)
	lid.closed.connect(_on_lid_closed)
	
	mounted_crank_snap_zone.has_dropped.connect(_on_crank_picked_up)
	stashed_crank_snap_zone.has_dropped.connect(_on_crank_picked_up)
	mounted_crank_snap_zone.has_picked_up.connect(_on_crank_inserted)
	stashed_crank_snap_zone.has_picked_up.connect(_on_crank_stashed)
	crank_crankable.crank_cranked.connect(_on_crank_cranked)
	
	filter_system.picked_up.connect(_on_filter_picked_up)
	filter_system.mounted.connect(_on_filter_mounted)
	filter_system.stashed.connect(_on_filter_stashed)
	
	mounted_vinyl_snap_zone.has_picked_up.connect(_on_vinyl_mounted)
	mounted_vinyl_snap_zone.has_dropped.connect(_on_vinyl_picked_up)
	stashed_vinyl_snap_zone_cole_porter.has_picked_up.connect(_on_vinyl_stashed)
	stashed_vinyl_snap_zone_cole_porter.has_dropped.connect(_on_vinyl_picked_up)
	
	lid.tonearm.mounted.connect(_on_tonearm_mounted)
	lid.tonearm.stashed.connect(_on_tonearm_stashed)
	
	brake.disengaged.connect(_on_brake_disengaged)
	brake.engaged.connect(_on_brake_engaged)
	
	await _warmup_all_vinyls()
	_refresh_permissions()


func _physics_process(_delta: float) -> void:
	if mounted_vinyl and state == State.PLAYING:
		mounted_vinyl.get_node("Model").rotate_y(deg_to_rad(60 * _delta))


func _refresh_permissions():
	lid.set_interactable(false)
	
	crank_pickable.set_interactable(false)
	crank_crankable.set_interactable(false)
	mounted_crank_snap_zone.set_active(false)
	stashed_crank_snap_zone.set_active(false)
	
	filter_system.set_active(false)
	
	#TODO: Repeat for all vinyls
	mounted_vinyl_snap_zone.set_active(false)
	vinyl_cole_porter.set_interactable(false)
	stashed_vinyl_snap_zone_cole_porter.set_active(false)
	
	lid.tonearm.reset()
	
	brake.set_interactable(false)
	
	match state:
		State.LID_CLOSED:
			state_label.text = "LID_CLOSED"
			instructions_label.text = "Open the lid"
			
			lid.set_interactable(true)
			lid.set_outline_shader_params(Color(1,1,0,0.3), 1)
		
		State.LID_OPEN:
			state_label.text = "LID_OPEN"
			instructions_label.text = "Pick up the crank \n - OR - \n Close the lid"
			
			crank_pickable.set_interactable(true)
			mounted_crank_snap_zone.set_active(true)
			mounted_crank_snap_zone.set_highlight_visible(false)
			stashed_crank_snap_zone.set_active(true)
			stashed_crank_snap_zone.set_highlight_visible(false)
			
			lid.set_interactable(true)
			lid.set_outline_shader_params(Color(1,0.4,0,0.3), 1)
		
		State.CRANK_PICKED_UP:
			state_label.text = "CRANK_PICKED_UP"
			instructions_label.text = "Insert the crank \n - OR - \n Stash the crank"
			
			crank_pickable.set_interactable(true)
			mounted_crank_snap_zone.set_active(true)
			stashed_crank_snap_zone.set_active(true)
		
		State.CRANK_INSERTED:
			state_label.text = "CRANK_INSERTED"
			
			crank_pickable.set_visible(false)
			crank_crankable.set_visible(true)
			crank_crankable.set_interactable(true)
			
			if _is_cranked:
				_on_crank_cranked()
			else:
				instructions_label.text = "Crank the crank"
		
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
			state_label.text = "FILTER_PICKED_UP"
			instructions_label.text = "Mount the filter \n - OR - \n Stash the filter"
			filter_system.set_active(true)

		State.FILTER_MOUNTED:
			state_label.text = "FILTER_MOUNTED"
			instructions_label.text = "Pick up any vinyl \n - OR - \n Pick up the filter to stash it"
			
			vinyl_cole_porter.set_interactable(true)
			stashed_vinyl_snap_zone_cole_porter.set_active(true)
			
			filter_system.set_active(true)
		
		State.VINYL_PICKED_UP:
			state_label.text = "VINYL_PICKED_UP"
			instructions_label.text = "Mount or stash the picked up vinyl"
			
			mounted_vinyl_snap_zone.set_active(true)
			if not stashed_vinyl_snap_zone_cole_porter.has_snapped_object():
				stashed_vinyl_snap_zone_cole_porter.set_active(true)
				vinyl_cole_porter.set_interactable(true)
		
		State.VINYL_MOUNTED:
			state_label.text = "VINYL_MOUNTED"
			instructions_label.text = "Mount the tonearm \n - OR - \n Remove the vinyl"
			lid.tonearm.expect_mount()
			
			mounted_vinyl_snap_zone.set_active(true)
			mounted_vinyl.set_interactable(true)
		
		State.TONEARM_MOUNTED:
			state_label.text = "TONEARM_MOUNTED"
			instructions_label.text = "Disengage the brake to play \n - OR - \n Stash the tonearm"
			
			brake.set_interactable(true)
			
			lid.tonearm.expect_stash()
		
		State.PLAYING:
			state_label.text = "PLAYING"
			instructions_label.text = "Engage the brake to stop playing"
			
			brake.set_interactable(true)


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
	
	crank_pickable.set_visible(true)
	crank_crankable.set_visible(false)
	
	state = State.CRANK_CRANKED
	_refresh_permissions()

func _on_crank_stashed(_what: Variant):
	#if state != State.CRANK_PICKED_UP:
		#return
	
	# TODO: Sometimes reset the crank, it cant give infinite playback
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


# Vinyl

func _on_vinyl_picked_up():
	state = State.VINYL_PICKED_UP
	
	# Not the cleanest solution but it works
	if mounted_vinyl:
		mounted_vinyl = null
	
	_refresh_permissions()

func _on_vinyl_mounted(_what: Variant):
	state = State.VINYL_MOUNTED
	
	mounted_vinyl = mounted_vinyl_snap_zone.picked_up_object as Vinyl
	
	_refresh_permissions()

func _on_vinyl_stashed(_what: Variant):
	state = State.FILTER_MOUNTED
	_refresh_permissions()


# Tonearm

func _on_tonearm_mounted():
	state = State.TONEARM_MOUNTED
	_refresh_permissions()

func _on_tonearm_stashed():
	state = State.VINYL_MOUNTED
	_refresh_permissions()


# Brake

func _on_brake_disengaged():
	if state != State.TONEARM_MOUNTED:
		return
	
	state = State.PLAYING
	
	# Only change the stream if the vinyl is different or if no stream is loaded
	if not audio_player.stream or audio_player.stream.resource_path != mounted_vinyl.song.resource_path:
		audio_player.stream = mounted_vinyl.song.audio_stream
		audio_player.play()
	else:
		# Resume playback if it's the same vinyl
		audio_player.stream_paused = false
	
	_refresh_permissions()


func _on_brake_engaged():
	if state != State.PLAYING:
		return
	
	state = State.TONEARM_MOUNTED
	
	audio_player.stream_paused = true
	
	_refresh_permissions()


# AUDIO WARMUP

func _warmup_all_vinyls() -> void:
	#TODO: Repeat for all vinyls
	var vinyls: Array[Vinyl] = [vinyl_cole_porter]
	for vinyl in vinyls:
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
