extends VBoxContainer

var compile_notification_t = preload("res://src/ui/simple_notification/SimpleNotiifcation.tscn")
var collapsable_t = preload("res://src/ui/collapsable/collapsable.tscn")

signal request_filepath(type)
signal show_editor(show)
signal create_notification(node, timemout)
signal grab_focus

onready var close_btn: ToolButton = $VBoxContainer2/Close
onready var editor_switch: ToolButton = $VBoxContainer2/EditorSwitch
onready var file_path_header: Label = $VBoxContainer2/SketchPath

onready var compile_btn: Button = $PaddingBox2/SketchButtons/Compile
onready var pause_btn: Button = $PaddingBox2/SketchButtons/Pause
onready var start_btn: Button = $PaddingBox2/SketchButtons/Start

onready var reset_pos_btn: Button = $PaddingBox/VehicleButtons/Reset
onready var follow_btn: Button = $PaddingBox/VehicleButtons/Follow

onready var attachments = $Scroll/Attachments
onready var attachments_empty = $Scroll/Attachments/empty

onready var log_box = $Log

onready var serial_collapsable = $Serial
onready var uart = $Serial/UartPanel/Uart
onready var sketch_log = $Log/SketchLog/VBoxContainer/LogBox

var runner: BoardRunner = null
var sketch_path: String = ""

var vehicle_t: PackedScene = null
var vehicle = null


func _ready():
	runner = SketchAttach.make_runner()
	
	for sig in ["configured", "building", "built", "started", "suspended_resumed", "stopped", "cleaned"]:
		runner.connect(sig, self, "_on_runner_" + sig)

	# TODO: move this into its own scene
	runner.connect("build_log", self, "_on_board_log")
	runner.connect("runtime_log", self, "_on_board_log")
	
	compile_btn.connect("pressed", self, "_on_compile")
	close_btn.connect("pressed", self, "_on_close")
	pause_btn.connect("pressed", self, "_on_pause")
	editor_switch.connect("toggled", self, "_on_editor_toggled")
	start_btn.connect("pressed", self, "_on_start")
	reset_pos_btn.connect("pressed", self, "_on_reset_pos")
	follow_btn.connect("pressed", self, "_on_follow")
	
	uart.set_uart(runner.uart())
	
	var group = BButtonGroup.new()
	$Log/Button.group = group
	$Serial/Button.group = group
	group._init()
	
	_on_runner_cleaned()


func _on_runner_cleaned() -> void:
	print("Sketch cleaned")
	pause_btn.disabled = true
	start_btn.disabled = true
	pause_btn.disabled = true
	reset_pos_btn.disabled = true
	follow_btn.disabled = true


func _on_runner_configured() -> void:
	print("Sketch configured")
	compile_btn.disabled = false


var _building_notification = null
func _on_runner_building() -> void:
	print("Building")
	
	_building_notification = _create_notification("Compiling sketch '%s' ..." % file_path_header.text, -1, true)
	
	sketch_log.text = ""
	compile_btn.disabled = true


func _on_runner_built(result) -> void:
	_building_notification.emit_signal("stop_notify")
	
	if ! result.ok():
		print("Compile failed: ", result.error())
		_create_notification("Build failed for sketch '%s':\nReason: \"%s\"" % [file_path_header.text, result.error()], 5)
		compile_btn.disabled = false
		log_box.header.pressed = true
		return
	
	print("Compile finished succesfully")
	_create_notification("Compile succeeded for sketch '%s'" % file_path_header.text , 5)
	
	_create_vehicle()
	
	start_btn.disabled = false
	start_btn.text = "Start"
	serial_collapsable.disabled = false
	uart.disabled = false


func _on_runner_started() -> void:
	print("Sketch Started")
	sketch_log.text = ""
	pause_btn.disabled = false
	reset_pos_btn.disabled = false
	start_btn.text = "Stop"
	follow_btn.disabled = false
	vehicle.unfreeze()


func _on_runner_suspended_resumed(suspended: bool) -> void:
	pause_btn.text = "Resume" if suspended else "Suspend"
	
	if suspended:
		vehicle.freeze()
	else:
		vehicle.unfreeze()


func _on_runner_stopped(exit_code: int) -> void:
	print("Sketch stopped: ", exit_code)
	if exit_code > 0:
		_create_notification("Sketch '%s' crashed!\n[color=gray]Open the sketch log for more details.[/color]" % file_path_header.text, 5)
		log_box.header.pressed = true
	
	attachments_empty.visible = true
	start_btn.text = "Start"
	start_btn.disabled = true
	compile_btn.disabled = false
	pause_btn.disabled = true
	reset_pos_btn.disabled = true
	serial_collapsable.disabled = true
	follow_btn.disabled = true
	uart.disabled = true
	uart.console.text = ""
	
	vehicle.queue_free()


var cam_ctl: CamCtl = null setget set_cam_ctl

func set_cam_ctl(ctl: CamCtl) -> void:
	if ! ctl:
		return
	cam_ctl = ctl
	cam_ctl.connect("cam_locked", self, "_on_cam_ctl")
	cam_ctl.connect("cam_freed", self, "_on_cam_ctl", [null])

func set_filepath(path: String):
	if path == "":
		return Util.err("Invalid sketch path")
	
	var base = path.get_base_dir().get_file()
	var file = path.get_basename().get_file()
	if base != file:
		return Util.err("Folder name should equal selected file name")
	
	sketch_path = path
	
	var board_config = BoardConfigGD.from_dict(Util.read_json_file("res://src/config/smartcar_shield.json"))
	
	var res = runner.init(OS.get_user_data_dir())
	if ! res.ok():
		return res
	
	res = runner.configure("arduino:sam:arduino_due_x", board_config)
	if ! res.ok():
		return res

	if path.ends_with("tank.ino"):
		vehicle_t = preload("res://src/objects/ray_car/RayTank.tscn")
	else:
		vehicle_t = preload("res://src/objects/ray_car/RayCar.tscn")

	file_path_header.text = path.get_file()

	return GDResult.new()

# TODO: move this into its own scene
func _on_board_log(part: String):
	sketch_log.text += part


func _on_compile() -> void:
	if runner.status() != SMCE.Status.CONFIGURED:
		var res = runner.reset(true)
		if res.ok():
			runner.build(sketch_path)
		else:
			_create_notification("Failed to reinitialize: '%s'" % res.error(), 5)
	else:
		runner.build(sketch_path)


func _on_close() -> void:
	if runner:
		runner.set_free()
	queue_free()


func _on_cam_ctl(node) -> void:
	follow_btn.text = "Unfollow" if vehicle == node else "Follow"


func _on_follow() -> void:
	if cam_ctl.locked == vehicle:
		cam_ctl.free_cam()
	else:
		cam_ctl.lock_cam(vehicle)


func _on_reset_pos() -> void:
	reset_vehicle_pos()


func _on_start() -> void:
	match runner.status():
		SMCE.Status.RUNNING, SMCE.Status.SUSPENDED:
			Util.print_if_err(runner.terminate())
		SMCE.Status.BUILT:
			Util.print_if_err(runner.start())


func _on_pause() -> void:
	if runner.status() == SMCE.Status.RUNNING:
		Util.print_if_err(runner.suspend())
	elif runner.status() == SMCE.Status.SUSPENDED:
		Util.print_if_err(runner.resume())


func _on_editor_toggled(toggle) -> void:
	emit_signal("show_editor", toggle)


func _create_notification(text: String, timeout: float = -1, progress: bool = false, button: bool = false) -> Control:
	var notification: Control = compile_notification_t.instance()
	emit_signal("create_notification", notification, timeout)
	notification.progress.visible = progress
	notification.button.visible = button
	notification.header.bbcode_text = text
	notification.connect("pressed", self, "emit_signal", ["grab_focus"])
	
	# TODO: dont do this here
	if timeout > 0:
		notification.connect("pressed", notification, "emit_signal", ["stop_notify"])
	
	connect("tree_exiting", notification, "emit_signal", ["stop_notify"])
	
	return notification


func _create_vehicle() -> void:
	vehicle = vehicle_t.instance()
	add_child(vehicle)
	
	vehicle.set_view(runner.view())
	vehicle.freeze()
	
	_setup_attachments()
	reset_vehicle_pos()


func _setup_attachments() -> void:
	attachments_empty.visible = vehicle.attachments.empty()
	for attachment in vehicle.attachments:
		var collapsable = collapsable_t.instance()
		collapsable.set_header_text(attachment.name)
		if attachment.has_method("visualize"):
			collapsable.add_child(attachment.visualize())
		attachments.add_child(collapsable)
		attachment.connect("tree_exited", collapsable, "call", ["queue_free"])


func reset_vehicle_pos() -> void:
	if !vehicle:
		return
	var was_frozen = vehicle.frozen
	vehicle.freeze()
	vehicle.global_transform.origin = Vector3(0,3,0)
	vehicle.global_transform.basis = Basis()
	if ! was_frozen:
		vehicle.unfreeze()
