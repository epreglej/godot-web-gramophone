extends XRToolsInteractableHinge
class_name XRToolsInteractableHingeScoped

func _get_owning_hinge(node: Node) -> XRToolsInteractableHinge:
	var current := node.get_parent()
	while current:
		if current is XRToolsInteractableHinge:
			return current
		current = current.get_parent()
	return null

# Override
func _process(_delta: float) -> void:
	# If no handles are grabbed, do nothing
	if grabbed_handles.is_empty():
		return

	# Sum angular offsets from valid handles only
	var offset_sum := 0.0
	var valid_count := 0

	for item in grabbed_handles:
		var handle := item as XRToolsInteractableHandle
		if handle == null:
			continue

		# IMPORTANT FILTER:
		# Only accept handles whose nearest hinge ancestor is THIS hinge
		if _get_owning_hinge(handle) != self:
			continue

		var to_handle: Vector3 = handle.global_transform.origin * global_transform
		var to_handle_origin: Vector3 = handle.handle_origin.global_transform.origin * global_transform
		to_handle.x = 0.0
		to_handle_origin.x = 0.0

		offset_sum += to_handle_origin.signed_angle_to(to_handle, Vector3.RIGHT)
		valid_count += 1

	# No valid handles → no movement
	if valid_count == 0:
		return

	# Average the angular offsets
	var offset := offset_sum / valid_count

	# Move the hinge
	move_hinge(_hinge_position_rad + offset)
