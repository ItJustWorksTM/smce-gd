class_name SketchOwner
extends Node

signal reset
signal build_log
signal runtime_log

export (PackedScene) var vehicle_scene = null
export (NodePath) var spawn_point_path = ""
onready var spawn_point: Position3D = get_node_or_null(spawn_point_path)

var board: BoardRunner = null
var vehicle: Spatial = null
var file_path: String = ""

var _fqbin = "arduino:avr:nano"
var _board_config = null

func init(
	path: String, board_config = _board_config, fqbin: String = _fqbin, context: String = OS.get_user_data_dir()
) -> bool:
	if path == "" && ! File.new().file_exists(path):
		return false

	_fqbin = fqbin
	_board_config = board_config
	
	var new_board = BoardRunner.new()

	if ! (
		new_board.init_context(context)
		&& new_board.configure(fqbin, board_config)
		&& new_board.status() == SMCE.Status.CONFIGURED
	):
		return false

	add_child(new_board)
	board = new_board
	board.connect("status_changed", self, "_on_board_status_changed")
	board.connect("build_log", self, "_on_build_log")
	board.connect("runtime_log", self, "_on_runtime_log")
	
	file_path = path

	return true

func _on_build_log(part: String) -> void:
	emit_signal("build_log", part)

func _on_runtime_log(part: String) -> void:
	emit_signal("runtime_log", part)

func reset(force: bool = false) -> void:
	if !force && board && board.status() == SMCE.Status.CONFIGURED:
		return

	if board:
		board.queue_free()
	if vehicle:
		vehicle.queue_free()
	board = null
	vehicle = null
	# TOOD: error handling if this fails
	init(file_path)
	emit_signal("reset")


func reset_vehicle_pos() -> void:
	if vehicle:
		vehicle.freeze()
		if spawn_point:
			vehicle.global_transform = spawn_point.global_transform
		else:
			vehicle.global_transform.origin = Vector3(0, 3, 0)
		vehicle.unfreeze()


func build() -> bool:
	if ! board || board.status() != SMCE.Status.CONFIGURED:  # TODO: potentially not a coroutine in this case
		return false
	var res = yield(board.build(file_path), "completed")
	if ! res:
		reset(true)
		return false
	print("build finished")
	_create_vehicle()
	print("created vehicle")

	return true


func start() -> bool:
	if ! board || ! board.start():
		return false

	return true


func _create_vehicle() -> bool:
	if ! board || vehicle || ! vehicle_scene:
		return false

	var new_vehicle: Spatial = vehicle_scene.instance()
	new_vehicle.freeze()

	add_child(new_vehicle, true)
	# maybe needed
	# yield(new_vehicle, "ready")

	new_vehicle.set_runner(board)
	vehicle = new_vehicle
	reset_vehicle_pos()
	return true


func toggle_suspend() -> bool:
	if ! board:
		return false

	if board.suspend():
		return false
	else:
		return board.resume()


func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE && board:
		board.terminate()


func _on_board_status_changed(status) -> void:
	if status == SMCE.Status.STOPPED:
		reset()
	if vehicle:
		if status == SMCE.Status.SUSPENDED:
			vehicle.freeze()
		elif status == SMCE.Status.RUNNING:
			vehicle.unfreeze()
