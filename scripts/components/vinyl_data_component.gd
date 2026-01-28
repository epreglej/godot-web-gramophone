extends Node
class_name VinylDataComponent

## Holds vinyl song data and provides song information

@export var song_a: Song  # Side A song
@export var song_b: Song  # Side B song

var _flippable_component: FlippableComponent = null

func _ready():
	# Find flippable component to track current side
	_flippable_component = get_parent().get_node_or_null("%FlippableComponent") as FlippableComponent
	if not _flippable_component:
		_flippable_component = get_parent().get_node_or_null("FlippableComponent") as FlippableComponent

func get_current_song() -> Song:
	var side = _flippable_component.get_current_side() if _flippable_component else 0
	return song_a if side == 0 else song_b

func get_other_song() -> Song:
	var side = _flippable_component.get_current_side() if _flippable_component else 0
	return song_b if side == 0 else song_a

func get_current_side_name() -> String:
	if _flippable_component:
		return _flippable_component.get_current_side_name()
	return "A"

func get_other_side_name() -> String:
	if _flippable_component:
		return _flippable_component.get_other_side_name()
	return "B"

func get_song_info() -> String:
	var song = get_current_song()
	var side_name = get_current_side_name()
	if song:
		return "Side %s: %s - %s" % [side_name, song.artist, song.title]
	return "Side %s: Unknown" % side_name

func get_other_side_info() -> String:
	var song = get_other_song()
	var other_side = get_other_side_name()
	if song:
		return "Side %s: %s - %s" % [other_side, song.artist, song.title]
	return "Side %s: Unknown" % other_side
