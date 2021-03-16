extends CenterContainer

signal created(node)

var control_pane_t = preload("res://src/ui/sketch_control/ControlPane.tscn")

signal request_filepath(node, type)

onready var open_file_btn: Button = $VBoxContainer/HBoxContainer/OpenFile
onready var error_label: Label = $VBoxContainer/Error


func set_filepath(path: String) -> void:
	# Since cancel has been pressed we dont have to bother
	if path == "":
		return
	var control_pane = control_pane_t.instance()
	get_parent().add_child(control_pane)
	var res = control_pane.set_filepath(path)
	if ! res.ok():
		error_label.text = "Failed: %s" % res.error()
		control_pane.free()
		print("Sketch init err: ", res.error())
		return

	emit_signal("created", control_pane)
	queue_free()


func _ready() -> void:
	open_file_btn.connect("pressed", self, "_on_create_pressed")


func _on_create_pressed() -> void:
	emit_signal("request_filepath", FileDialog.MODE_OPEN_FILE, self)
	pass
