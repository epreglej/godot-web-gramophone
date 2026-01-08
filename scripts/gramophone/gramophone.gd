extends Node
class_name Gramophone

@export var audio_player: AudioStreamPlayer3D
@export var settings_ui: SettingsUI

@export var lid: Lid

@export var filter: Filter
@export var mounted_filter_snap_zone: FilterSnapZone
@export var stashed_filter_snap_zone: FilterSnapZone

@export var crank_pickable: CrankPickable
@export var crank_crankable: CrankCrankable
@export var mounted_crank_snap_zone: CrankSnapZone
@export var stashed_crank_snap_zone: CrankSnapZone

@export var mounted_vinyl_snap_zone: VinylSnapZone
@export var vinyl_cole_porter: Vinyl
@export var stashed_vinyl_snap_zone_cole_porter: VinylSnapZone
@export var vinyl_conchita_martinez: Vinyl
@export var stashed_vinyl_snap_zone_conchita_martinez: VinylSnapZone


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
	
	BRAKE_DISENGAGED,
	
	TONEARM_MOUNTED
}

const COLOR_GREEN: Color = Color(0,1,0,0.4)
const COLOR_YELLOW: Color = Color(1,1,0,0.4)

var color_assemble: Color = COLOR_GREEN
var color_disassemble: Color = COLOR_YELLOW

var state: State = State.LID_CLOSED
var mounted_vinyl: Vinyl = null

var _last_played_audio_stream: AudioStream = null

# TODO: Reset it to false after adding the cranking to the crank
var _is_cranked: bool = false
var _state_before_crank_depleted: State = State.CRANK_INSERTED


func _ready():
	await settings_ui.content_ready
	await _warmup_all_vinyls()
	
	crank_crankable.set_visible(false)
	
	crank_pickable.set_interactable(true)
	stashed_crank_snap_zone.set_active(true)
	stashed_crank_snap_zone.pick_up_object(crank_pickable)
	stashed_crank_snap_zone.set_active(false)
	crank_pickable.set_interactable(false)
	
	filter.set_interactable(true)
	stashed_filter_snap_zone.set_active(true)
	stashed_filter_snap_zone.pick_up_object(filter)
	stashed_filter_snap_zone.set_active(false)
	filter.set_interactable(false)
	
	#TODO: Repeat for all vinyls
	vinyl_cole_porter.set_interactable(true)
	stashed_vinyl_snap_zone_cole_porter.set_active(true)
	stashed_vinyl_snap_zone_cole_porter.pick_up_object(vinyl_cole_porter)
	stashed_vinyl_snap_zone_cole_porter.set_active(false)
	vinyl_cole_porter.set_interactable(false)
	
	vinyl_conchita_martinez.set_interactable(true)
	stashed_vinyl_snap_zone_conchita_martinez.set_active(true)
	stashed_vinyl_snap_zone_conchita_martinez.pick_up_object(vinyl_conchita_martinez)
	stashed_vinyl_snap_zone_conchita_martinez.set_active(false)
	vinyl_conchita_martinez.set_interactable(false)
	
	# Connect signals to callbacks
	lid.opened.connect(_on_lid_opened)
	lid.closed.connect(_on_lid_closed)
	
	mounted_crank_snap_zone.has_dropped.connect(_on_crank_picked_up)
	stashed_crank_snap_zone.has_dropped.connect(_on_crank_picked_up)
	mounted_crank_snap_zone.has_picked_up.connect(_on_crank_inserted)
	stashed_crank_snap_zone.has_picked_up.connect(_on_crank_stashed)
	crank_crankable.crank_cranked.connect(_on_crank_cranked)
	
	mounted_filter_snap_zone.has_dropped.connect(_on_filter_picked_up)
	stashed_filter_snap_zone.has_dropped.connect(_on_filter_picked_up)
	mounted_filter_snap_zone.has_picked_up.connect(_on_filter_mounted)
	stashed_filter_snap_zone.has_picked_up.connect(_on_filter_stashed)
	
	#TODO: Repeat for all vinyls
	mounted_vinyl_snap_zone.has_picked_up.connect(_on_vinyl_mounted)
	mounted_vinyl_snap_zone.has_dropped.connect(_on_vinyl_picked_up)
	stashed_vinyl_snap_zone_cole_porter.has_picked_up.connect(_on_vinyl_stashed)
	stashed_vinyl_snap_zone_cole_porter.has_dropped.connect(_on_vinyl_picked_up)
	stashed_vinyl_snap_zone_conchita_martinez.has_picked_up.connect(_on_vinyl_stashed)
	stashed_vinyl_snap_zone_conchita_martinez.has_dropped.connect(_on_vinyl_picked_up)
	
	lid.tonearm.mounted.connect(_on_tonearm_mounted)
	lid.tonearm.stashed.connect(_on_tonearm_stashed)
	
	brake.disengaged.connect(_on_brake_disengaged)
	brake.engaged.connect(_on_brake_engaged)
	
	_refresh_permissions()


func _physics_process(delta: float) -> void:
	# TODO: Reset the roatation of the model after picking up the vinyl
	if mounted_vinyl and (state == State.BRAKE_DISENGAGED or state == State.TONEARM_MOUNTED):
		mounted_vinyl.get_node("SnapPivot").get_node("Model").rotate_y(deg_to_rad(60 * delta))


func _refresh_permissions():
	lid.set_interactable(false)
	
	crank_pickable.set_interactable(false)
	crank_crankable.set_interactable(false)
	mounted_crank_snap_zone.set_active(false)
	stashed_crank_snap_zone.set_active(false)
	
	filter.set_interactable(false)
	mounted_filter_snap_zone.set_active(false)
	stashed_filter_snap_zone.set_active(false)
	
	#TODO: Repeat for all vinyls
	mounted_vinyl_snap_zone.set_active(false)
	vinyl_cole_porter.set_interactable(false)
	stashed_vinyl_snap_zone_cole_porter.set_active(false)
	vinyl_conchita_martinez.set_interactable(false)
	stashed_vinyl_snap_zone_conchita_martinez.set_active(false)
	
	lid.tonearm.reset()
	
	brake.set_interactable(false)
	
	match state:
		State.LID_CLOSED:
			settings_ui.set_instructions("Open the lid")
			
			lid.set_outline_shader_color(color_assemble)
			lid.set_interactable(true)
		
		State.LID_OPEN:
			settings_ui.set_instructions("Pick up the crank \n - OR - \n Close the lid")
			
			crank_pickable.set_outline_shader_color(color_assemble)
			crank_pickable.set_interactable(true)
			mounted_crank_snap_zone.set_active(true)
			mounted_crank_snap_zone.set_highlight_visible(false)
			stashed_crank_snap_zone.set_active(true)
			stashed_crank_snap_zone.set_highlight_visible(false)
			
			lid.set_outline_shader_color(color_disassemble)
			lid.set_interactable(true)
		
		State.CRANK_PICKED_UP:
			settings_ui.set_instructions("Insert the crank \n - OR - \n Stash the crank")
			
			crank_pickable.set_interactable(true)
			crank_pickable.set_outline_visible(false)
			mounted_crank_snap_zone.set_highlight_color(color_assemble)
			stashed_crank_snap_zone.set_highlight_color(color_disassemble)
			mounted_crank_snap_zone.set_active(true)
			stashed_crank_snap_zone.set_active(true)
		
		State.CRANK_INSERTED:
			crank_pickable.set_visible(false)
			crank_crankable.set_visible(true)
			crank_crankable.set_outline_shader_color(COLOR_GREEN)
			crank_crankable.set_interactable(true)
			
			if _is_cranked:
				_on_crank_cranked()
			else:
				settings_ui.set_instructions("Crank the crank")
		
		State.CRANK_CRANKED:
			settings_ui.set_instructions("Pick up the filter \n - OR - \n Pick up the crank to stash it")
			
			filter.set_outline_shader_color(color_assemble)
			filter.set_interactable(true)
			mounted_filter_snap_zone.set_active(true)
			mounted_filter_snap_zone.set_highlight_visible(false)
			stashed_filter_snap_zone.set_active(true)
			stashed_filter_snap_zone.set_highlight_visible(false)
			
			crank_pickable.set_outline_shader_color(color_disassemble)
			crank_pickable.set_interactable(true)
			mounted_crank_snap_zone.set_active(true)
			mounted_crank_snap_zone.set_highlight_visible(false)
			stashed_crank_snap_zone.set_active(true)
			stashed_crank_snap_zone.set_highlight_visible(false)
		
		State.FILTER_PICKED_UP:
			settings_ui.set_instructions("Mount the filter \n - OR - \n Stash the filter")
			
			filter.set_interactable(true)
			mounted_filter_snap_zone.set_highlight_color(color_assemble)
			stashed_filter_snap_zone.set_highlight_color(color_disassemble)
			mounted_filter_snap_zone.set_active(true)
			stashed_filter_snap_zone.set_active(true)
		
		State.FILTER_MOUNTED:
			settings_ui.set_instructions("Pick up any vinyl \n - OR - \n Pick up the filter to stash it")
			
			#TODO: Repeat for all vinyls
			vinyl_cole_porter.set_interactable(true)
			stashed_vinyl_snap_zone_cole_porter.set_active(true)
			vinyl_conchita_martinez.set_interactable(true)
			stashed_vinyl_snap_zone_conchita_martinez.set_active(true)
			
			filter.set_interactable(true)
			mounted_filter_snap_zone.set_active(true)
			mounted_filter_snap_zone.set_highlight_visible(false)
			stashed_filter_snap_zone.set_active(true)
			stashed_filter_snap_zone.set_highlight_visible(false)
		
		State.VINYL_PICKED_UP:
			settings_ui.set_instructions("Mount or stash the picked up vinyl")
			
			#TODO: Repeat for all vinyls
			mounted_vinyl_snap_zone.set_active(true)
			if not stashed_vinyl_snap_zone_cole_porter.has_snapped_object():
				stashed_vinyl_snap_zone_cole_porter.set_active(true)
				vinyl_cole_porter.set_interactable(true)
			elif not stashed_vinyl_snap_zone_conchita_martinez.has_snapped_object():
				stashed_vinyl_snap_zone_conchita_martinez.set_active(true)
				vinyl_conchita_martinez.set_interactable(true)
		
		State.VINYL_MOUNTED:
			settings_ui.set_instructions("Disengage the brake \n - OR - \n Remove the vinyl")
			
			brake.set_interactable(true)
			
			mounted_vinyl_snap_zone.set_active(true)
			mounted_vinyl.set_interactable(true)
		
		State.BRAKE_DISENGAGED:
			settings_ui.set_instructions("Mount the tonearm to start playing \n - OR - \n Engage the brake")
			
			lid.tonearm.expect_mount()
			
			brake.set_interactable(true)
		
		State.TONEARM_MOUNTED:
			settings_ui.set_instructions("Stash the tonearm to stop playing")
			
			lid.tonearm.expect_stash()


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
	if state != State.CRANK_PICKED_UP:
		return
	
	state = State.CRANK_INSERTED
	_refresh_permissions()


func _on_crank_cranked():
	# Maybe there shouldn't be a checker here because
	# it should be possible to creank the crank when
	# it finally unwinds
	
	crank_pickable.set_visible(true)
	crank_crankable.set_visible(false)
	
	_is_cranked = true
	
	state = State.CRANK_CRANKED
	_refresh_permissions()


func _on_crank_stashed(_what: Variant):
	if state != State.CRANK_PICKED_UP:
		return
	
	# TODO: Sometimes reset the crank, it cant give infinite playback
	#_is_cranked = false
	
	state = State.LID_OPEN
	_refresh_permissions()


# FILTER

func _on_filter_picked_up():
	if state != State.CRANK_CRANKED and state != State.FILTER_MOUNTED:
		return
	
	state = State.FILTER_PICKED_UP
	_refresh_permissions()


func _on_filter_mounted(_what: Variant):
	if state != State.FILTER_PICKED_UP:
		return
	
	state = State.FILTER_MOUNTED
	
	_refresh_permissions()


func _on_filter_stashed(_what: Variant):
	if state != State.FILTER_PICKED_UP:
		return
	
	state = State.CRANK_CRANKED
	
	_refresh_permissions()


# Vinyl

func _on_vinyl_picked_up():
	if mounted_vinyl:
		mounted_vinyl.get_node("SnapPivot").get_node("Model").basis = Basis.IDENTITY
	
	# When user picks up the vinyl, we should reset the playback cache
	_last_played_audio_stream = null
	
	state = State.VINYL_PICKED_UP
	
	_refresh_permissions()


func _on_vinyl_mounted(_what: Variant):
	mounted_vinyl = mounted_vinyl_snap_zone.picked_up_object as Vinyl
	
	state = State.VINYL_MOUNTED
	
	_refresh_permissions()


func _on_vinyl_stashed(_what: Variant):
	# Not the cleanest solution but it works
	if mounted_vinyl:
		mounted_vinyl = null
	
	state = State.FILTER_MOUNTED
	
	_refresh_permissions()


# Brake

func _on_brake_disengaged():
	if state != State.VINYL_MOUNTED:
		return
	
	state = State.BRAKE_DISENGAGED
	
	_refresh_permissions()


func _on_brake_engaged():
	if state != State.BRAKE_DISENGAGED:
		return

	state = State.VINYL_MOUNTED
	
	_refresh_permissions()


# Tonearm

func _on_tonearm_mounted():
	if state != State.BRAKE_DISENGAGED:
		return
	
	state = State.TONEARM_MOUNTED
	
	_start_or_resume_playback()
	
	_refresh_permissions()


func _on_tonearm_stashed():
	if state != State.TONEARM_MOUNTED:
		return
	
	state = State.BRAKE_DISENGAGED
	
	audio_player.stream_paused = true
	
	_refresh_permissions()


# AUDIO HELPERS

func _get_current_song_stream() -> AudioStream:
	if mounted_vinyl == null:
		return null

	return mounted_vinyl.song.audio_stream


func _start_or_resume_playback() -> void:
	var stream := _get_current_song_stream()
	if stream == null:
		return

	if _last_played_audio_stream != stream:
		audio_player.stream = stream
		audio_player.play()
		_last_played_audio_stream = stream
	else:
		audio_player.stream_paused = false


func _warmup_all_vinyls() -> void:
	#TODO: Repeat for all vinyls
	var vinyls: Array[Vinyl] = [vinyl_cole_porter, vinyl_conchita_martinez]
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
