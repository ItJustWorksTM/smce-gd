extends VBoxContainer

var compile_notification_t = preload("res://src/ui/simple_notification/SimpleNotiifcation.tscn")
var collapsable_t = preload("res://src/ui/collapsable/collapsable.tscn")

signal request_filepath(type)
signal show_editor(show)
signal create_notification(node, timemout)
signal grab_focus

onready var close_button: ToolButton = $VBoxContainer2/Close
onready var editor_switch: ToolButton = $VBoxContainer2/EditorSwitch
onready var file_path_header: Label = $VBoxContainer2/SketchPath

onready var compile_btn: Button = $PaddingBox2/SketchButtons/Compile
onready var pause_btn: Button = $PaddingBox2/SketchButtons/Pause
onready var start_btn: Button = $PaddingBox2/SketchButtons/Start

onready var reset_pos_btn: Button = $PaddingBox/VehicleButtons/Reset
onready var follow_btn: Button = $PaddingBox/VehicleButtons/Follow

onready var attachments = $Scroll/Attachments
onready var attachments_empty = $Scroll/Attachments/empty

onready var serial_collapsable = $Serial
onready var uart = $Serial/UartPanel/Uart
onready var sketch_log = $Log/SketchLog/VBoxContainer/LogBox

var controller: SketchOwner = null

var cam_ctl: CamCtl = null setget set_cam_ctl

func set_cam_ctl(ctl: CamCtl) -> void:
	if ! ctl:
		return
	cam_ctl = ctl
	cam_ctl.connect("cam_locked", self, "_on_cam_ctl")
	cam_ctl.connect("cam_freed", self, "_on_cam_ctl", [null])

func set_filepath(path: String) -> bool:
	if controller:
		return false

	var ctrl: SketchOwner = SketchOwner.new()
	var board_config = preload("res://src/config/smartcar_shield/board_config.tres")
	
	if ! ctrl.init(path, board_config):
		return false

	ctrl.connect("reset", self, "_on_controller_reset")

	if path.ends_with("tank.ino"):
		ctrl.vehicle_scene = preload("res://src/objects/ray_car/RayTank.tscn")
	else:
		ctrl.vehicle_scene = preload("res://src/objects/ray_car/RayCar.tscn")

	ctrl.board.connect("status_changed", self, "_on_board_status_changed")
	ctrl.connect("build_log", self, "_on_board_log")
	ctrl.connect("runtime_log", self, "_on_board_log")
	
	controller = ctrl
	# TODO: do this somewhere else
	compile_btn.connect("pressed", self, "build")
	compile_btn.disabled = false

	uart.set_runner(controller.board)

	add_child(ctrl)

	file_path_header.text = path.get_file()

	return true

func _on_board_log(part: String):
	sketch_log.text += part


func _on_controller_reset() -> void:
	controller.board.connect("status_changed", self, "_on_board_status_changed")
	uart.set_runner(controller.board)


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


func build() -> void:
	print("compiling")
	sketch_log.text = ""
	
	var notification = _create_notification("Compiling sketch '%s' ..." % file_path_header.text, -1, true)
	
	compile_btn.disabled = true
	var result = yield(controller.build(), "completed")

	notification.emit_signal("stop_notify")
	if ! result:
		_create_notification("Compile failed for sketch '%s'" % file_path_header.text, 5)
		compile_btn.disabled = false
		return
	
	_create_notification("Compile succeeded for sketch '%s'" % file_path_header.text , 5)
	
	start_btn.disabled = false

	print("compiling finished: ", result)
	_setup_attachments()


func _setup_attachments() -> void:
	attachments_empty.visible = controller.vehicle.attachments.empty()
	
	for attachment in controller.vehicle.attachments:
		var collapsable = collapsable_t.instance()
		collapsable.set_header_text(attachment.name())
		collapsable.add_child(attachment.visualize())
		attachments.add_child(collapsable)
		attachment.connect("tree_exited", collapsable, "call", ["queue_free"])
		

func _ready():
	pause_btn.disabled = true
	start_btn.disabled = true
	pause_btn.disabled = true
	compile_btn.disabled = true
	reset_pos_btn.disabled = true

	close_button.connect("pressed", self, "queue_free")
	pause_btn.connect("pressed", self, "_on_pause_button")
	editor_switch.connect("toggled", self, "_on_editor_toggled")
	start_btn.connect("pressed", self, "_on_start_button")
	reset_pos_btn.connect("pressed", self, "_on_reset_pos")
	follow_btn.connect("pressed", self, "_on_follow_button")
	
	var group = BButtonGroup.new()
	$Log/Button.group = group
	$Serial/Button.group = group
	group._init()

func _on_cam_ctl(node) -> void:
	if controller.vehicle == node:
		follow_btn.text = "Unfollow"
	else:
		follow_btn.text = "Follow"


func _on_follow_button() -> void:
	if cam_ctl.locked == controller.vehicle:
		cam_ctl.free_cam()
	else:
		cam_ctl.lock_cam(controller.vehicle)


func _on_reset_pos() -> void:
	if controller:
		controller.reset_vehicle_pos()


func _on_start_button() -> void:
	match controller.board.status():
		SMCE.Status.RUNNING, SMCE.Status.SUSPENDED:
			controller.reset()
		SMCE.Status.BUILT:
			controller.start()


func _on_pause_button() -> void:
	if ! controller:
		return
	if controller.toggle_suspend():
		pause_btn.text = "Suspend"
	else:
		pause_btn.text = "Resume"
	pass


func _on_editor_toggled(toggle) -> void:
	emit_signal("show_editor", toggle)


func _on_board_status_changed(status) -> void:
	print("Status: ", SMCE.Status.keys()[status])
	
	match status:
		SMCE.Status.BUILT:
			start_btn.disabled = false
			start_btn.text = "Start"
			serial_collapsable.disabled = false
		SMCE.Status.RUNNING:
			sketch_log.text = ""
			pause_btn.disabled = false
			reset_pos_btn.disabled = false
			start_btn.text = "Stop"
			follow_btn.disabled = false
		SMCE.Status.STOPPED:
			if controller.board.get_exit_code() > 0:
				_create_notification("Sketch '%s' crashed!\n[color=gray]Open the sketch log for more details.[/color]" % file_path_header.text, 5)
			attachments_empty.visible = true
			start_btn.text = "Start"
			start_btn.disabled = true
			compile_btn.disabled = false
			pause_btn.disabled = true
			reset_pos_btn.disabled = true
			serial_collapsable.disabled = true
			follow_btn.disabled = true
			
			
