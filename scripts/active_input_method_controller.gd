extends XROrigin3D

@export var left_joystick_controller: XRController3D
@export var left_hand_controller: XRController3D
@export var left_hand_origin: XRNode3D
@export var hand_pose_detector: HandPoseDetector
@export var label: Label3D

func _process(_delta):
	if not hand_pose_detector or not hand_pose_detector.hand_tracker:
		return

	# Check if the palm is tracked
	var flags := hand_pose_detector.hand_tracker.get_hand_joint_flags(XRHandTracker.HAND_JOINT_PALM)
	var using_hands: bool = false
	if (flags & XRHandTracker.HAND_JOINT_FLAG_POSITION_TRACKED) != 0 \
	   and (flags & XRHandTracker.HAND_JOINT_FLAG_ORIENTATION_TRACKED) != 0:
		using_hands = true

	# Optional: you can also check if a pose is currently active
	# using_hands = hand_pose_detector._current_pose != null

	var using_controller := not using_hands

	# Debug print
	print("hands:", using_hands, " controller:", using_controller)

	# Update label
	if label:
		label.text = "hands: " + str(using_hands) + " controller: " + str(using_controller)

	# Controller visibility & processing
	left_joystick_controller.visible = using_controller
	left_joystick_controller.process_mode = (
		Node.PROCESS_MODE_INHERIT if using_controller
		else Node.PROCESS_MODE_DISABLED
	)

	# Hand pose controller visibility & processing
	left_hand_controller.visible = using_hands
	left_hand_controller.process_mode = (
		Node.PROCESS_MODE_INHERIT if using_hands
		else Node.PROCESS_MODE_DISABLED
	)

	# Hand origin visibility & processing
	left_hand_origin.visible = using_hands
	left_hand_origin.process_mode = (
		Node.PROCESS_MODE_INHERIT if using_hands
		else Node.PROCESS_MODE_DISABLED
	)
