extends Control
class_name Main

# Mesage of the day: tween a bool for happiness


class UserSketch:
	extends Sketch


class VoidHardware:
	static func get_type() -> String: return "Void"
	
	var pins: Dictionary

	func request(builder):
		
		pass

var user_config = {
	vehicle = "SmartCar",
	hardware = [
		{
			type = "VoidHardware",
			pins = [ { pin = 1, analog = true }, { pin = 2, digital = true } ]
			# etc etc, basically the old board config
		},
		{
			type = "BrushedMotor",
			label = "Right BrushedMotor",
			forward_pin = 25,
			backward_pin = 26,
			enable_pin = 27
		},
		{
			type = "Camera",
			label = "Front Camera"
		},
		{
			type = "UartSlurper",
			label = "UartGui"
		},
		{
			type = "DigitalFS",
			label = "FilesystemGui",
			path = "/home/ruthgerd/virtualfs"
		}
	]
}

class Continue:
	signal cont

var dump = "wooop woop"



func _ready():
	
	

	# we have a list of Hardware, labeled and properties applied
	
	# we have a list of functions
	
	var sketch := Sketch.new()
	sketch.source = "/home/ruthgerd/demo/demo.ino"
	
	var manifest_registry := ManifestRegistry.new()
	
	var version := Ui.dedup_value("???")
	version.changed.connect(func(): DisplayServer.window_set_title("SMCE-gd %s" % version.value))
	version.value = "2.0.0-dev"
	
	var resource_directory := Ui.dedup_value("")
	resource_directory.changed.connect(func():
		print("TODO: copy RtResources into resource directory")
	)
	resource_directory.value = OS.get_user_data_dir()
	
	var board_config := BoardConfig.new()
	board_config.uart_channels += [UartChannelConfig.new()]
	board_config.gpio_drivers += [GpioPin.new()]
	board_config.pins = [0]
	
	var default_board_config := Ui.value(board_config)
	
	var sketch_config := SketchConfig.new()
	sketch_config.legacy_preproc_libs = ["MQTT@2.5.0", "WiFi@1.2.7", "Arduino_OV767X@0.0.2", "SD@1.2.4"]
	
	var default_sketch_config := Ui.value(sketch_config)
	
	var vehicle_config = VehicleConfig.new()
	
	var default_vehicle_config := Ui.value(vehicle_config)
	
	var sketch_cache = Ui.value({ "" = Sketch.new() })
	var cached_sketches = Ui.map(sketch_cache, func(cache: Directory): return cache.keys())
	
	var try_user_sketch_config = func(path: String) -> SketchConfig:
		if Fs.file_exists(path):
				if true:
					printerr("Failed to deserialize user sketch config")
					return null
		return null
	
	var new_sketch = func(path: String):
		var sk := Sketch.new()
		sk.source = path
		sk.config = default_sketch_config.value
		
		var user_sketch_config_path = path.get_base_dir().plus_file("sketch_config.json")
		var user_sketch_config = try_user_sketch_config.call(user_sketch_config_path)
		if user_sketch_config:
			sk.config = user_sketch_config
		
		return sk
	
	
	var attachment = {
		attachment_name = Ui.value("Cannon"),
		inspector = Ui.value(func(ctx): ctx \
			.inherits(Widgets.button()) \
			.with("text", "Shoooot!") \
			.with("theme_type_variation", "ButtonPrimary") \
			.with("vertical_alignment", VERTICAL_ALIGNMENT_CENTER) \
			.with("size_flags_vertical", SIZE_EXPAND_FILL)
		)
	}
	
	var make = func(sketch_p): return {
		sketch_path = Ui.value(sketch_p),
		build_state = Ui.value(InstanceControl.BUILD_UNKNOWN),
		build_log = Ui.value(dump),
		build_error = Ui.value(null),
		board_state = Ui.value(InstanceControl.BOARD_UNAVAILABLE),
		attachments = TrackedVec.new([attachment, attachment]),
		vehicle_state = Ui.value(InstanceControl.VEHICLE_UNAVAILABLE),
		camera_state = Ui.value(InstanceControl.CAMERA_FREE),
	}



	var sketches := TrackedVec.new([make.call("StockFish.ino")])
	
	var active_sketch = Ui.value(-1)
	
	var file_mode = Ui.value(FilePicker.SELECT_FILE)
	var filters = Ui.value([["Arduino", ["*.ino", "*.pde"]], ["C++", ["*.cpp", "*.hpp", "*.hxx", "*.cxx"]], ["Any", ["*"]]])

	var picking_file = Ui.value(false)
	
	var root = Ui.make_ui_root(func(ctx): ctx \
		.inherits(MarginContainer) \
		.child(func(ctx: Ctx): ctx \
			.inherits(MultiInstance.multi_instance(sketches, active_sketch)) \
			.on("compile_sketch", func(i): 
				sketches.index_mut(i, func(v):
					v.build_state.value = InstanceControl.BUILD_PENDING
					print(" compiling for real !! ...")
					
					if true:
						v.build_state.value = InstanceControl.BUILD_SUCCEEDED
						v.board_state.value = InstanceControl.BOARD_READY
					else:
						v.build_state.value = InstanceControl.BUILD_FAILED
						v.board_state.value = InstanceControl.BOARD_UNAVAILABLE


					print(" compile finished !! ...")
					return v
				)\
			) \
			.on("create_sketch", func():
				picking_file.value = true \
			) \

			.on("remove_pressed", func(i):
				print("deleteing ", i)
				sketches.remove(i) \
			) \
			.on("toggle_orbit", func(i):
				sketches.index_mut(i, func(v):
					v.camera_state.value = (v.camera_state.value - 1) * -1
					return v \
				) \
			) \
			.on("toggle_suspend", func(i):
				sketches.index_mut(i, func(v):
					v.board_state.value = InstanceControl.BOARD_RUNNING if v.board_state.value == InstanceControl.BOARD_SUSPENDED else InstanceControl.BOARD_SUSPENDED
					v.vehicle_state.value = InstanceControl.VEHICLE_FROZEN if v.board_state.value == InstanceControl.BOARD_SUSPENDED else InstanceControl.VEHICLE_ACTIVE
					return v \
				) \
			) \
			.on("toggle_board", func(i): \
				sketches.index_mut(i, func(v):
					var board_active = Ui.map(v.board_state, func(state): return state == InstanceControl.BOARD_RUNNING || state == InstanceControl.BOARD_SUSPENDED)
					
					if !board_active.value:
						print("starting board!")
					else:
						print("stooppped")
					
					v.board_state.value = InstanceControl.BOARD_READY if board_active.value else InstanceControl.BOARD_RUNNING
#					if board_active.value: v.attachments.append_array(["Left brushed-motor", "Right brushed-motor", "Gyroscope", "yeet"])
#					else: v.attachments.clear()
					v.vehicle_state.value = InstanceControl.VEHICLE_ACTIVE if board_active.value else InstanceControl.VEHICLE_UNAVAILABLE
					if !board_active.value:
						v.camera_state.value = InstanceControl.CAMERA_FREE
					return v \
				) \
			) \
		) \
		.children(Ui.child_if(picking_file, func(ctx): ctx \
			.inherits(CenterContainer) \
			.child(func(ctx): ctx \
				.inherits(FilePicker.filepicker(file_mode, filters)) \
				.on("completed", func(path: String):
					picking_file.value = false
					sketches.push(make.call(path.get_file()))
					active_sketch.value = sketches.size() - 1 \
				) \
				.on("cancelled", func(): picking_file.value = false)
			)
		)) \

	)
	
	
	$MarginContainer.add_child(root)
