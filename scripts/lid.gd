extends Node3D
class_name Lid


signal opened
signal closed

enum State {INACTIVE, EXPECT_OPEN, EXPECT_CLOSE}

@export var outline: MeshInstance3D
@export var animation_player: AnimationPlayer
@export var interactable_hinge: XRToolsInteractableHinge
@export var interactable_handle: XRToolsInteractableHandle
@export var tonearm_origin: Node3D

var state: State = State.INACTIVE

var _is_animation_playing: bool = false


func _ready() -> void:
	interactable_hinge.hinge_moved.connect(_on_hinge_moved)
	
	#_set_interactable(false)


func expect_open() -> void:
	state = State.EXPECT_OPEN
	set_highlight_color(Color(0,1,0), 1.5)
	_set_interactable(true)


func expect_close() -> void:
	state = State.EXPECT_CLOSE
	set_highlight_color(Color(1,0,0), 1.0)
	_set_interactable(true)


func _set_interactable(value: bool) -> void:
	interactable_handle.enabled = value
	outline.visible = value


func _on_hinge_moved(angle: float) -> void:
	if _is_animation_playing:
		return
	
	match state:
		State.EXPECT_OPEN:
			if angle <= -50.0 and angle >= -90.0:
				_is_animation_playing = true
				_set_interactable(false)
				
				animation_player.play("Opening")
				await animation_player.animation_finished
				
				state = State.INACTIVE
				_is_animation_playing = false
				opened.emit()
		
		State.EXPECT_CLOSE:
			if angle >= -40.0 and angle <= 0.0:
				_is_animation_playing = true
				_set_interactable(false)
				
				animation_player.play("Closing")
				await animation_player.animation_finished
				
				state = State.INACTIVE
				_is_animation_playing = false
				closed.emit()


func set_highlight_color(color: Color, glow_speed: float) -> void:
	var mat := outline.get_surface_override_material(0)
	
	if mat is ShaderMaterial:
		mat.set_shader_parameter("shell_color", color)
		mat.set_shader_parameter("glow_speed", glow_speed)
