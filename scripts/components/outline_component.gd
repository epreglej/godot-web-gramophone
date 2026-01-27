extends Node
class_name OutlineComponent

## Handles outline visibility and color management
## Works with any object that has an outline Node3D

@export var outline: Node3D

func _ready():
	if outline:
		_set_outline_visibility(false)

func set_outline_visible(value: bool):
	_set_outline_visibility(value)

func set_outline_color(color: Color):
	if not outline:
		return
	# Find all mesh instances in outline and set shader color
	_set_shader_color_recursive(outline, color)

func _set_outline_visibility(value: bool):
	if outline:
		outline.visible = value

func _set_shader_color_recursive(node: Node, color: Color):
	if node is MeshInstance3D:
		var mesh_instance := node as MeshInstance3D
		# Check surface material overrides first
		for i in range(mesh_instance.get_surface_override_material_count()):
			var mat = mesh_instance.get_surface_override_material(i)
			if mat is ShaderMaterial:
				mat.set_shader_parameter("shell_color", color)
		# Also check mesh materials
		if mesh_instance.mesh:
			for i in range(mesh_instance.mesh.get_surface_count()):
				var mat = mesh_instance.mesh.surface_get_material(i)
				if mat is ShaderMaterial:
					mat.set_shader_parameter("shell_color", color)
	# Recurse into children
	for child in node.get_children():
		_set_shader_color_recursive(child, color)
