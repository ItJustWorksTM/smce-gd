class_name Defaults

static func user_config(): return {
	hardware = {
		"Left BrushedMotor": {
			type = "BrushedMotor",
			fwd_pin = 10,
			bwd_pin = 11,
			enable_pin = 11,
		},
		"Right BrushedMotor": {
			type = "BrushedMotor",
			fwd_pin = 35,
			bwd_pin = 36,
			enable_pin = 37,
		},
		"Top Ultrasound": {
			type = "SR04",
			echo_pin = 16,
			trigger_pin = 17,
		},
		"Gui Uart": {
			type = "UartPuller"
		}
	},
	vehicle = {
		lmotor = "Left BrushedMotor",
		rmotor = "Right BrushedMotor",
		slot_top = "Top Ultrasound"
	},
	ui = {
		uart = "Gui Uart"
	}
}
