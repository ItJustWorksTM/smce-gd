#
#  ControlPane.gd
#  Copyright 2021 ItJustWorksTM
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#

extends VBoxContainer

var notification_t = preload("res://src/ui/simple_notification/SimpleNotification.tscn")
var collapsable_t = preload("res://src/ui/collapsable/collapsable.tscn")
var code_main_window_t = preload("res://src/ui/code_editor/MainWindow.tscn")

signal notification_created
signal grab_focus

var _toolchain: Toolchain = null
var _board = null

onready var edit_sketch_btn = $SketchSlot/VBoxContainer2/HBoxContainer/HBoxContainer/EditButton
onready var compile_btn: Button = $SketchSlot/VBoxContainer2/HBoxContainer/HBoxContainer/Compile
onready var compile_log_btn: Button = $SketchSlot/VBoxContainer2/HBoxContainer/HBoxContainer/CompileLog
onready var sketch_status: Label = $SketchSlot/VBoxContainer2/VBoxContainer/SketchStatus

onready var close_btn: ToolButton = $MarginContainer/CloseButton
onready var file_path_header: Label = $SketchSlot/VBoxContainer2/VBoxContainer/SketchPath

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

var sketch_path: String = ""

var cam_ctl: CamCtl = null setget set_cam_ctl

var vehicle = null

var code_editor = null

func init(sketch: Sketch, toolchain: Toolchain):
	
	sketch_path = sketch.get_source()
	
	
	var board_config = BoardConfig.new()
	var stock_config =  Util.read_json_file("res://share/config/smartcar_shield_board.json")
	var json_config = Util.read_json_file(sketch_path.get_base_dir().plus_file("board_config.json"))
	if json_config == null:
		json_config = stock_config
	elif ! json_config.get("from_scratch", false):
		json_config = Util.merge_dict(stock_config, json_config)
		print("Using patched board config")
	else:
		print("Using board config from scratch")
	assert(json_config)
	
	for i in range(json_config.get("sd_cards", []).size()):
		var root_dir = json_config["sd_cards"][i].get("root_dir", "")
		if root_dir.is_rel_path():
			root_dir = sketch_path.get_base_dir().plus_file(root_dir)
		json_config["sd_cards"][i]["root_dir"] = root_dir
	
	Util.inflate_ref(board_config, json_config)
	
	var board = Board.new()
	
	var res = board.configure(board_config)
	if ! res.ok():
		board.free()
		return res
	
	var attach_res = board.attach_sketch(sketch)
	if ! attach_res.ok():
		board.free()
		return attach_res
	
	_toolchain = toolchain
	_board = board
	
	_toolchain.connect("building", self, "_on_toolchain_building")
	_toolchain.connect("built", self, "_on_toolchain_built")
	_toolchain.connect("log", self, "_on_toolchain_log")
	
	add_child(board)
	
	return GDResult.new()


func _ready():
	for sig in ["started", "suspended_resumed", "stopped", "cleaned"]:
		_board.connect(sig, self, "_on_board_" + sig)
	
	_board.connect("log", self, "_on_board_log")
	
	edit_sketch_btn.connect("pressed", self, "_on_edit_btn")
	compile_btn.connect("pressed", self, "_on_compile")
	compile_log_btn.connect("pressed", self, "_show_compile_log")
	
	close_btn.connect("pressed", self, "_on_close")
	pause_btn.connect("pressed", self, "_on_pause")
	start_btn.connect("pressed", self, "_on_start")
	reset_pos_btn.connect("pressed", self, "_on_reset_pos")
	follow_btn.connect("pressed", self, "_on_follow")
	
	
	uart.set_uart(_board.uart())
	file_path_header.text = " " + sketch_path.get_file().get_file()
	
	var group = BButtonGroup.new()
	$Log/Button.group = group
	$Serial/Button.group = group
	group._init()
	
	
	_on_board_cleaned()
	if _board.get_sketch().is_compiled():
		_built()

func _on_edit_btn() -> void:
	get_focus_owner().release_focus()
	if (code_editor == null):
		code_editor = code_main_window_t.instance()
		code_editor.src_file = sketch_path
		code_editor.sketch_owner = self
		get_tree().root.add_child(code_editor)
		code_editor.compile_btn.visible = true
	else:
		code_editor.enableEditor()

func _on_board_cleaned() -> void:
	sketch_status.text = " Not Compiled" if ! _toolchain.is_building() else " Compiling..."
	pause_btn.disabled = true
	start_btn.disabled = true
	pause_btn.disabled = true
	reset_pos_btn.disabled = true
	follow_btn.disabled = true
	compile_btn.disabled = _toolchain.is_building()


func _on_toolchain_building(sketch) -> void:
	if sketch != _board.get_sketch():
		return
	
	sketch_log.text = ""
	sketch_status.text = " Compiling..."
	compile_btn.disabled = true
	start_btn.disabled = true
	
	_board.terminate()


func _on_toolchain_built(sketch, result) -> void:
	if sketch != _board.get_sketch():
		return
	
	compile_btn.disabled = false
	
	if ! result.ok():
		sketch_status.text = " Not Compiled"
		return
	_built()


func _built():
	start_btn.disabled = false
	start_btn.text = "Start"
	serial_collapsable.disabled = false
	uart.disabled = false
	sketch_status.text = " Compiled"


func _on_board_started() -> void:
	print("Sketch Started")
	_create_vehicle()
	vehicle.unfreeze()
	
	sketch_log.text = ""
	uart.console.text = ""	
	pause_btn.disabled = false
	reset_pos_btn.disabled = false
	start_btn.text = "Stop"
	follow_btn.disabled = false


func _on_board_suspended_resumed(suspended: bool) -> void:
	pause_btn.text = "Resume" if suspended else "Suspend"
	
	if suspended:
		vehicle.freeze()
	else:
		vehicle.unfreeze()


func _on_board_stopped(exit_code: int) -> void:
	var exit_str = str(exit_code)
	if exit_code < 0:
		exit_code &= 0xFFFFFFFF
	if exit_code > 255 || exit_code < 0:
		exit_str = "0x%X" % exit_code
	
	print("Sketch stopped: ", exit_str)
	if exit_code != 0:
		var notif = _create_notification("Sketch '%s' crashed!\nexit code: %s" % [file_path_header.text, exit_str], 5)
		# notif.connect("pressed", self, "emit_signal", ["grab_focus"])
		log_box.header.pressed = true
	
	attachments_empty.visible = true
	start_btn.text = "Start"
	pause_btn.disabled = true
	reset_pos_btn.disabled = true
	follow_btn.disabled = true
	uart.disabled = true
	
	vehicle.queue_free()


func set_cam_ctl(ctl: CamCtl) -> void:
	if ! ctl:
		return
	cam_ctl = ctl
	cam_ctl.connect("cam_locked", self, "_on_cam_ctl")
	cam_ctl.connect("cam_freed", self, "_on_cam_ctl", [null])


func _on_board_log(part: String):
	sketch_log.text += part


func _on_compile() -> void:
	if ! _toolchain.compile(_board.get_sketch()):
		_create_notification("Failed to start compilation", 5)


func _on_close() -> void:
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
	match _board.status():
		SMCE.Status.RUNNING, SMCE.Status.SUSPENDED:
			Util.print_if_err(_board.terminate())
			return
	
	Util.print_if_err(_board.start())


func _on_pause() -> void:
	if _board.status() == SMCE.Status.RUNNING:
		Util.print_if_err(_board.suspend())
	elif _board.status() == SMCE.Status.SUSPENDED:
		Util.print_if_err(_board.resume())


func _create_notification(text: String, timeout: float = -1, progress: bool = false, button: bool = false) -> Control:
	var notification: Control = notification_t.instance().setup(self, text, timeout, progress, button)
	
	emit_signal("notification_created", notification, timeout)
	notification.connect("pressed", self, "emit_signal", ["grab_focus"])
	
	return notification


var compile_log_text_field = null
func _show_compile_log() -> void:
	var window = preload("res://src/ui/sketch_control/LogPopout.tscn").instance()
	get_tree().root.add_child(window)
	compile_log_text_field = RichTextLabel.new()
	compile_log_text_field.scroll_following = true
	window.set_text_field(compile_log_text_field)
	compile_log_text_field.text = _toolchain.get_log()


func _on_toolchain_log(text) -> void:
	if is_instance_valid(compile_log_text_field):
		compile_log_text_field.text += text


func _create_vehicle() -> void:
	
	var stock_config = Util.read_json_file("res://share/config/smartcar_shield_vehicle.json")
	var json_config = Util.read_json_file(sketch_path.get_base_dir().plus_file("vehicle_config.json"))
	
	if json_config == null:
		json_config = stock_config
		if sketch_path.ends_with("tank.ino"):
			json_config["vehicle"] = "RayTank"
	elif ! json_config.get("from_scratch", false):
		json_config = Util.merge_dict(stock_config, json_config)
		print("Using patched vehicle config")
	else:
		print("Using vehicle config from scratch")
	assert(json_config)
	
	var vehicle_name = json_config.get("vehicle", "")
	var vehicle_scene = Global.vehicles.get(vehicle_name)
	
	# TODO: handle failure
	assert(vehicle_scene is PackedScene, "Specified vehicle does not exist!")
	
	vehicle = vehicle_scene.instance()
	add_child(vehicle)
	
	vehicle.set_view(_board.view())
	
	print("Using vehicle: %s" % vehicle_name)
	var attachments = []
	print("Attachments:")
	for slot_name in json_config.get("slots", {}):
		var slot = json_config["slots"][slot_name]
		var attachment_class = slot.get("class")
		var attachment_name = slot.get("name")
		var script = Global.classes.get(attachment_class)
		assert(attachment_class && script)
		
		var attachment: Node = script.new()
		
		if attachment_name != null:
			attachment.name = attachment_name
		Util.set_props(attachment, slot.get("props", {}))
		
		print("class: %s, name: %s " % [attachment_class, attachment.name])
		var res = vehicle.add_aux_attachment(slot_name, attachment)
		if ! res.ok():
			printerr(res.error())
	
	var builtin_attachments = vehicle.get_node_or_null("BuiltinAttachments")
	if builtin_attachments != null:
		var builtin_props = json_config.get("builtin", {})
		for attach in builtin_attachments.get_children():
			Util.set_props(attach, builtin_props.get(attach.name, {}))
	
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
	if !is_instance_valid(vehicle):
		return
	var was_frozen = vehicle.frozen
	vehicle.freeze()
	vehicle.global_transform.origin = Vector3(0,3,0)
	vehicle.global_transform.basis = Basis()
	if ! was_frozen:
		vehicle.unfreeze()


func _notification(what):
	if what == NOTIFICATION_PREDELETE && is_instance_valid(compile_log_text_field):
		compile_log_text_field.queue_free()
