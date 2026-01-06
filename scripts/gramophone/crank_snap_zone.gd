@tool
extends XRToolsSnapZone
class_name CrankSnapZone

@export var highlight: MeshInstance3D


func set_active(value: bool) -> void:
	self.enabled = value
	highlight.visible = value

func set_highlight_visible(value: bool) -> void:
	highlight.visible = value
