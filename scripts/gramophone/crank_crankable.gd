extends Node3D
class_name CrankCrankable

signal crank_cranked

@export var outline: MeshInstance3D
@export var animation_player: AnimationPlayer
@export var interactable_hinge: XRToolsInteractableHinge
@export var interactable_handle: XRToolsInteractableHandle

var _is_animation_playing: bool = false


func _ready() -> void:
	interactable_hinge.hinge_moved.connect(_on_hinge_moved)


func set_interactable(value: bool) -> void:
	interactable_handle.enabled = value
	outline.visible = value


func play_animation(animation_name: String) -> void:
	_is_animation_playing = true
	set_interactable(false)
	
	animation_player.play(animation_name)
	await animation_player.animation_finished
	
	set_interactable(true)
	_is_animation_playing = false


func set_highlight_color(color: Color, glow_speed: float) -> void:
	var mat2 := outline.get_surface_override_material(1)
	
	if mat2 is ShaderMaterial:
		mat2.set_shader_parameter("shell_color", color)
		mat2.set_shader_parameter("glow_speed", glow_speed)


func _on_hinge_moved(angle: float) -> void:
	if angle <= -1080.0:
		crank_cranked.emit()
