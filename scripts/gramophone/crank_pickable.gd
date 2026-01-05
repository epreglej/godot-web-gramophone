@tool
extends XRToolsPickable
class_name CrankPickable

@export var outline: MeshInstance3D


# Public API
func set_interactable(value: bool) -> void:
	self.enabled = value
	outline.visible = value


func set_highlight_color(color: Color, glow_speed: float) -> void:
	var mat := outline.get_surface_override_material(0)
	
	if mat is ShaderMaterial:
		mat.set_shader_parameter("shell_color", color)
		mat.set_shader_parameter("glow_speed", glow_speed)
		
	var mat2 := outline.get_surface_override_material(1)
	
	if mat2 is ShaderMaterial:
		mat2.set_shader_parameter("shell_color", color)
		mat2.set_shader_parameter("glow_speed", glow_speed)
