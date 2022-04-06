class_name Defaults

static func user_config(): return {
    inherits = "default",
    sketch = {
        rt_resources = OS.get_user_data_dir(),
        arduino_libs = ["MQTT@2.5.0", "WiFi@1.2.7", "Arduino_OV767X@0.0.2", "SD@1.2.4"],
        plugin_defs = {
            "SmartcarGyroPlugin": {
                defaults = 0,
                requires_devices = ["SmartcarGyro"],
                uri = "file:///home/ruthgerd/Documents/demo/plugins/TotallyOOP"
            },
            "Smartcar_shield": {
                defaults = 0,
                uri = "https://github.com/platisd/smartcar_shield/archive/refs/tags/7.0.1.tar.gz",
                patch_uri = "file:///home/ruthgerd/.local/share/godot/app_userdata/SMCE/library_patches/smartcar_shield",
            },
        },
        hardware = {
            "Left BrushedMotor": {
                type = "BrushedMotor",
                fwd_pin = 12,
                bwd_pin = 14,
                enable_pin = 13,
            },
            "Right BrushedMotor": {
                type = "BrushedMotor",
                fwd_pin = 25,
                bwd_pin = 26,
                enable_pin = 27,
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
    },
    vehicle = {
        name = "smartcar_shield",
        attachments = {
            left_motor = {
                type = "MotorDriver",
                hardware = { input = "Left BrushedMotor" },
                props = { drive_left_wheels = true }
            },
            right_motor = {
                type = "MotorDriver",
                hardware = { input = "Right BrushedMotor" },
                props = { drive_right_wheels = true }                
            },
        }
    },
    ui = {
        uart = "Gui Uart"
    }
}
