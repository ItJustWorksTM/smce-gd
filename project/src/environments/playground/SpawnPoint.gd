extends Spatial

signal build_started()
signal build_completed(error)
signal focus_changed(car)


var raycar_t = preload("res://src/objects/ray_car/RayCar.tscn")
var control_t = preload("res://src/ui/board_control/BoardControl.tscn")

var _managed: Array = []
var _pending: Array = []

var _active_ctl: Control = null

func _init():
	var newray = raycar_t.instance()
	add_child(newray)
	newray.queue_free()

func set_active(ctl: Control):
	if ctl == _active_ctl:
		return

	var tween: Tween = Tween.new()
	if _active_ctl:
		tween.interpolate_property(_active_ctl, "rect_position:x", 0, 440, 0.2)

	var focus = ctl.get_focus_owner()
	if focus:
		focus.release_focus()
	add_child(tween)

	ctl.visible = true
	_active_ctl = ctl
	tween.interpolate_property(ctl, "rect_position:x", 440, 0, 0.2)

	tween.start()
	yield(tween, "tween_all_completed")
	print("completed")
	tween.queue_free()


func _on_board_status_changed(status: int, instance: Spatial) -> void:
	if status == SMCE.Status.STOPPED:
		instance.queue_free()

func _on_car_clicked(
	camera: Node,
	event: InputEvent,
	position: Vector3,
	click_normal: Vector3,
	body_idx: int,
	car,
	ctl
) -> void:
	if event.is_action_pressed("mouse_left"):
		print("clicked", car)
		set_active(ctl)
		get_viewport().get_camera().target = car.get_path()


func _handle_build_end(root: Spatial, error = null) -> void:
	if error != null:
		root.queue_free()
	emit_signal("build_completed", error)

# TODO: free on failure
func compile_sketch(path: String, context: String = OS.get_user_data_dir()) -> void:
	emit_signal("build_started")
	var newray = raycar_t.instance()
	var top = Spatial.new()
	add_child(top)

	var runner = BoardRunner.new()
	
	top.add_child(runner)
	# runner.connect("status_changed", self, "_on_pending_status_changed", [top])

	if ! runner.init_context(context):
		print("failed to setup")
		return _handle_build_end(top, "Failed to intialize context")

	print("Setup context properly")

	if ! runner.configure("arduino:avr:nano"):
		print("failed to configure runner")
		return _handle_build_end(top, "Failed to configure runner")
	print("we configured")

	if ! yield(runner.build(path), "completed"):
		print("build failed")
		return _handle_build_end(top, "Failed to compile sketch")
	print("we build!")

	if ! runner.start():
		return _handle_build_end(top, "Failed to start sketch")
	
	print("we started!")

	var control = control_t.instance()
	control.visible = false
	top.add_child(control)

	control.runner = runner
	newray.set_runner(runner)
	newray.connect("input_event", self, "_on_car_clicked", [newray, control])
	top.add_child(newray)

	if ! _active_ctl:
		set_active(control)

	return _handle_build_end(top)
