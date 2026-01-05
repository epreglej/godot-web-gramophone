@tool
extends XRToolsSnapZone
class_name FilterSnapZone

@export var highlight: MeshInstance3D


func set_active(value: bool) -> void:
	self.enabled = value
	highlight.visible = value
