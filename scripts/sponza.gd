extends WorldEnvironment

func _ready():
	var interface = ARVRServer.find_interface("OpenVR")
	if interface and interface.initialize():
		get_viewport().arvr = true
		
		# swap this around if PR # 19724 has not been applied
		# get_viewport().hdr = false
		get_viewport().rgba8_out = true
		
		# for some reason the inspector won't let me set this up
		$OVRFirstPerson/Right_Hand.connect("button_pressed", $OVRFirstPerson/HUD_Anchor/Settings_VR, "_on_Right_Hand_button_pressed")
