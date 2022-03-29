class_name BoardState
extends Node

enum { BOARD_READY, BOARD_RUNNING, BOARD_SUSPENDED, BOARD_STAGING, BOARD_UNAVAILABLE }
enum { BUILD_PENDING, BUILD_SUCCEEDED, BUILD_FAILED, BUILD_UNKNOWN }

var cached_sketches := TrackedVec.new([])

var sketches := TrackedVec.new([])

var _sketches := []
var _boards := {}

var _sketch_state: SketchState

func _init(sketch_state):
	self._sketch_state = sketch_state


func _ready():
#	add_sketch("/home/ruthgerd/Documents/demo/demo.ino")
	pass

func add_board(sketch_id: int):
	var sketch: Sketch = self._sketch_state.sketches.index_item(sketch_id).v.value
	
#	var cached_index = cached_sketches.find_index(func(v): return v == path)
#
#	if cached_index >= 0:
#		pass
	
	var board = Board.new()
	_boards[board.get_instance_id()] = {"board": board, "requests": []}
	
	_sketches.push_back(sketch)
	sketches.push({
		"id": board.get_instance_id(),
		"sketch_id": sketch_id, 
		"compiled": false, 
		"board": BOARD_UNAVAILABLE,
		"board_log": "",
		"build": BUILD_UNKNOWN, 
		"build_log": ""
	})
#  no
func start_board(board_id: int):
	var pub_index = sketches.find_item(func(kv): return kv.v.value.id == board_id).k.value
	assert(pub_index != -1)
	
	_boards[board_id].requests = []
	
	var sketch = _sketch_state.get_sketch(_boards[board_id].sketch_id)
	
	# if the sketch is not compiled then we just fail
	
	
	var registry: ManifestRegistry = sketch.v.value.registry
	
	
	
	var sketch_mut = sketches.index_item_mut(pub_index).v
	
	sketch_mut.value.board = BOARD_STAGING
	
	# people request hardware
	
	var board: Board = _boards[board_id].board
	
	var config := BoardConfig.new()
	
	var give_out := []
	for request in _boards[board_id].requests:
		assert(request is HardwareBase)
		var demands = request.requires()
		
		var getters = []
		for demandc in demands:
			var demand = demandc.c
			if demand is GpioDriverConfig:
				if Fn.find_value(config.gpio_drivers, demand) == null:
					config.gpio_drivers.append(demand)
				getters.append(func(view: BoardView): return view.pins[demand.pin])
			elif demand is UartChannelConfig:
				var size = config.uart_channels.size()
				config.uart_channels.append(demand)
				getters.append(func(view: BoardView): return view.uart_channels[size])
			elif demand is FrameBufferConfig:
				if Fn.find_value(config.frame_buffers, demand) == null:
					config.frame_buffers.append(demand)
				getters.append(func(view: BoardView): return view.frame_buffers[demand.key])
			elif demand is BoardDeviceConfig:
				var bd: BoardDeviceConfig = Fn.find(
					config.board_devices, 
					func(v): return v.name == demand.name && v.version == demand.version
				)
				var size = 0
				if bd == null: config.board_devices.append(demand)
				else:
					bd.count += 1
					size = bd.count -1
				getters.append(func(view: BoardView):
					return view.board_devices[demand.device_name][size])
			elif demand is SecureDigitalStorageConfig:
				if Fn.find_value(config.sd_cards, demand) == null:
					config.sd_cards.append(demand)
				getters.append(func(view: BoardView): return view.sd_cards[demand.cspin])
		
		give_out.append(getters)
		# use await continue trick here.. 
		# do not forget that hardware needs to be childed to us :)
		pass
	
	var devices = config.board_devices
	var res: Result = board.initialize(registry, config)
	assert(res.is_ok())
	var view = board.get_view()
	for j in _boards[board_id].requests.size():
		var collect = []
		
		var obj: HardwareBase = _boards[board_id].requests[j]
		
		for z in give_out[j]:
			collect.append(z.call(board.get_view()))
		obj._rec = collect
		
		add_child(obj)
	
	_boards[board_id].requests = []

	sketch_mut.mut_scope(func(v):
		v.compiled = true
		v.board = BOARD_READY
		v.build_log = "tc_log_reader.read()"
		return v
	)

func _process(delta):
	
	for bd in _boards.values():
		var res = bd.board.poll()
		var log = bd.board.log_reader().read()
		if log != "" && log != null:
			print("board log: ", log)
		if res.is_err():
			print("board error!: ", res.get_value)
			assert(false)

func request_hardware(i: int, node: HardwareBase):
	assert(i in _boards)
	_boards[i].requests.append(node)

func toggle_board(i: int):
	assert(i in _boards)
	var pub_index = sketches.find_item(func(v): return v.v.value.id == i).k.value
	assert(pub_index != -1)
	
	var res = _boards[i].board.start(_sketches[pub_index])
	print(res.get_value())
	
	sketches.index_item_mut(pub_index).v.value.board = BOARD_RUNNING
	

func toggle_suspend(i: int):
	pass

func remove_sketch(i: int):
	sketches.remove(i)
	
