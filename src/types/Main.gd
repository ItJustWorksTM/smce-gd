#
#  Main.gd
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

class_name Main
extends Node



class ComboGrabBag:
	extends Node
	
	
	# We share the sketch
	var sketch: Sketch
	var sketch_config
	func _sketch():
		sketch.connect("locked_changed", self, "_on_sketch_lock")
	
	func _on_sketch_lock(locked: bool):
		stop()
	
	# We share the toolchain
	var toolchain: Toolchain
	
	# We own the board
	var board: Board
	var board_config: BoardConfig
	
	# We own the vehicle
	var vehicle: Node
	var vehicle_scene: PackedScene
	
	var attachments: Array
	
	func start():
		if board.get_status() != SMCE.BoardStatus.CLEAN:
			stop()
			board = board.new()

	func resume():
		if board.resume().is_ok():
			_resume_vehicle()

	func suspend():
		if board.suspend().is_ok():
			_suspend_vehicle()
	
	func stop():
		pass
	
	func get_board_config() -> BoardConfig:
		
		return null
	
	func get_vehicle_config():
		pass
	
	func compile():
		if !is_instance_valid(sketch) || !sketch.is_locked():
			return
		if !is_instance_valid(toolchain) || !toolchain.is_initialized() || !toolchain.is_building():
			return
		
		stop()
		
		var tc_res = toolchain.compile(sketch)
		if tc_res.is_err():
			printerr("bruh")
	
	func _physics_process(__):
		if board.is_active() && board.poll().is_err():
			board.terminate()
			_free_vehicle()
		
		if toolchain.is_building():
			toolchain.poll()
	
	func _create_vehicle():
		pass
	
	func _free_vehicle():
		pass
	
	func _suspend_vehicle():
		pass
	
	func _resume_vehicle():
		pass
	
var bags: Dictionary = {}

var universe := Universe.new()
var camera := ControllableCamera.new()

func _init(_env: EnvInfo):
	pass


var pending_builds: Array = []


var bundle_map := {}

func new_bundle() -> int:
	var id := randi()
	var bundle := ComboGrabBag.new()
	
	
	bundle_map[id] = bundle
	
	return id


func build_sketch(sketch: Sketch) -> Result:
	var ret = Result.new().set_ok(null)
	var tc = Toolchain.new()
	var res_dir = ""
	
	ret = tc.init(res_dir)
	if ret.is_err(): return ret
	
	ret = tc.compile(sketch)
	if ret.is_err(): return ret
	
	pending_builds.append(tc)
	
	return ret

var profile := Observable.new(Profile.new("Holy Land", [SketchDescriptor.new()]))
var active_sketch := Observable.new(null)

func _ready():
	add_child(universe)
	add_child(camera)
	camera.current = true
	
	assert(universe.set_world_to("Test/Test"))
	camera.set_target_transform(universe.active_world_node.get_camera_starting_pos_hint())
	
	
#	var vsketch_list: VerticalSketchList = VerticalSketchList.instance()
#	add_child(vsketch_list)
#	vsketch_list.init_model(profile, active_sketch)
#	vsketch_list.model.connect("select_sketch", self, "select_sketch")
#	vsketch_list.model.connect("create_new", self, "create_new_sketch")
	
	yield(get_tree().create_timer(3),"timeout")
	
	profile.value.sketches = []
	profile.emit_change()
	print("bruh")
	return
	var lol = ComboGrabBag.new()
	add_child(lol)
	
	var mng := ManagedSketch.new()
	if mng.init(
		"/home/ruthgerd/Sources/.tracking/smartcar-shield/examples/BareMinimum",
		"/home/ruthgerd/Sources/smce-gd2/.smcegd_home/library_patches",
		"/home/ruthgerd/Sources/smce-gd2/.smcegd_home/smce_resources").is_err():
			print("fucky wucky")
	
	print(mng.compile())
	yield(mng.toolchain, "ready")
	print(mng.toolchain.poll())


func select_sketch(sketch):
	print("select_sketch: ", sketch)
	active_sketch.value = sketch

func create_new_sketch():
	print("create_new_sketch")
	profile.value.sketches.append(SketchDescriptor.new())
	profile.emit_change()

