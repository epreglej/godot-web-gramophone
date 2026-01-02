extends XROrigin3D

@export var left_joystick_controller: XRController3D
@export var left_hand_controller: XRController3D
@export var left_hand_origin: XRNode3D
@export var label: Label3D

func _process(_delta):
	var tracker := XRServer.get_tracker("/user/hand_tracker/left")
	var hand_tracker := tracker as XRHandTracker

	var using_hands: bool = hand_tracker != null and hand_tracker.get_hand_joint_count() > 0
	var using_controller: bool = not using_hands

	label.text = "hands:" + str(using_hands) + " controller:" + str(using_controller)
	print("hands:", using_hands, " controller:", using_controller)

	# Controller
	left_joystick_controller.visible = using_controller
	left_joystick_controller.process_mode = (
		Node.PROCESS_MODE_INHERIT if using_controller
		else Node.PROCESS_MODE_DISABLED
	)

	# Hand pose controller
	left_hand_controller.visible = using_hands
	left_hand_controller.process_mode = (
		Node.PROCESS_MODE_INHERIT if using_hands
		else Node.PROCESS_MODE_DISABLED
	)

	# Hand origin
	left_hand_origin.visible = using_hands
	left_hand_origin.process_mode = (
		Node.PROCESS_MODE_INHERIT if using_hands
		else Node.PROCESS_MODE_DISABLED
	)
