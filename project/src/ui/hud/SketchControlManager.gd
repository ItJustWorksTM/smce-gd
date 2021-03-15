extends Control

signal _file_picked(path)

var button_t = preload("res://src/ui/hud/SketchButton.tscn")
var create_panel_t = preload("res://src/ui/sketch_create/Create.tscn")

onready var lpane = $LeftPane

onready var left_panel = $Panel/VBoxContainer
onready var attach = $Panel/VBoxContainer/Control

onready var new_sketch_btn = $Panel/VBoxContainer/ToolButton

onready var file_picker_backdrop = $Backdrop
onready var file_picker = $Backdrop/FilePicker

onready var notification_display = $Notifications

var button_group: BButtonGroup = BButtonGroup.new()

var buttons: Array = []

var cam_ctl: CamCtl = null

func _ready() -> void:
	button_group._init()
	new_sketch_btn.connect("pressed", self, "_on_sketch_btn")
	file_picker._wrapped.connect("file_selected", self, "_on_file_picked")
	file_picker._wrapped.get_cancel().connect("pressed", self, "_on_file_picked", [""])
	file_picker._wrapped.current_dir = OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS)


func _on_file_picked(path: String) -> void:
	file_picker.visible = false
	file_picker_backdrop.visible = false
	emit_signal("_file_picked", path)
	print(path)


func _set_vis(visible, nodes):
	yield(get_tree(), "idle_frame")
	var tween: Tween = Tween.new()
	add_child(tween)
	tween.interpolate_property(lpane, "rect_position:x", lpane.rect_position.x, 48 + -int(!visible) * lpane.rect_size.x, 0.2,Tween.TRANS_CUBIC)
	for node in nodes:
		if node != lpane:
			tween.interpolate_property(node, "modulate:a", node.modulate.a, int(visible), 0.2)
			tween.interpolate_property(node, "visible", node.visible, visible, 0.2)
	tween.start()
	yield(tween, "tween_all_completed")
	tween.queue_free()


func _on_sketch_btn() -> void:
	var new_button = button_t.instance()
	var new_create_panel = create_panel_t.instance()
	var attch = Control.new()

	lpane.add_child(attch)
	attch.add_child(new_create_panel)

	new_create_panel.connect("request_filepath", self, "_on_filepath_request")
	new_create_panel.connect("created", self, "_on_sketch_created", [attch, new_button])
	
	new_button.connect("toggled", self, "_set_vis", [[lpane, attch]])

	# new_sketch_ctl.connect("tree_exiting", self, "_on_sketch_stopped", [new_button])

	buttons.append(new_button)
	new_button.group = button_group
	button_group._init()
	left_panel.add_child_below_node(attach, new_button)
	get_focus_owner().release_focus()
	new_button.grab_focus()
	attach = new_button
	new_button.pressed = true
	_reset_numbering()


# TODO: bad naming
func _on_sketch_created(node, attch, button) -> void:
	node.connect("grab_focus", button, "set", ["pressed", true])
	node.connect("tree_exiting", self, "_on_sketch_panel_removed", [attch, button])
	node.connect("create_notification", notification_display, "add_notification")
	node.cam_ctl = cam_ctl
	


func _on_sketch_panel_removed(node, button) -> void:
	buttons.erase(button)
	button.queue_free()
	node.queue_free()
	_set_vis(false, [lpane])
	_reset_numbering()


func _reset_numbering() -> void:
	var i = 1
	for button in buttons:
		button.text = str(i)
		i += 1

	if ! buttons.empty():
		attach = buttons.back()
	else:
		attach = $Panel/VBoxContainer/Control


func _on_filepath_request(mode, node) -> void:
	#  TODO: reset file path

	get_focus_owner().release_focus()
	file_picker._wrapped.invalidate()
	file_picker._wrapped.popup()
	file_picker.visible = true
	file_picker_backdrop.visible = true
	
	node.set_filepath(yield(self, "_file_picked"))
