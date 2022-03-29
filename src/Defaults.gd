class_name Defaults

static func user_config(): return {
	inherits = "default",
	sketch = {
		plugins = ["SmartcarGyroPlugin"], # maybe just auto enable the defs?
		arduino_libs = ["MQTT@2.5.0", "WiFi@1.2.7", "Arduino_OV767X@0.0.2", "SD@1.2.4"],
		plugin_defs = {
			"SmartcarGyroPlugin": {
				defaults = 0,
				requires_devices = ["SmartcarGyro"],
				uri = "file://./the/place/to/be"
			},
			"Smartcar_shield": {
				defaults = 0,
				uri = "https://github.com/platisd/smartcar_shield/archive/refs/tags/7.0.1.tar.gz",
				patch_uri = "file://../library_patches/smartcar_shield",
			},
		},
	},
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
		"Nice Gyro": {
			type = "GY50"
		},
		"Gui Uart": {
			type = "UartPuller"
		}
	},
	vehicle = {
		attachments = {
			"lmotor": "Left BrushedMotor",
			"rmotor": "Right BrushedMotor",
			"slot_top": "Top Ultrasound"
		}
	},
	ui = {
		uart = "Gui Uart"
	}
}
