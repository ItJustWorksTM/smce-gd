class_name BoardState
extends Node

enum { BOARD_RUNNING, BOARD_CRASHED, BOARD_SUSPENDED, BOARD_STAGING, BOARD_UNAVAILABLE }

var boards := Track.array([])
var _boards := []

var _sketch_state: SketchState

func _init(sketch_state):
    self._sketch_state = sketch_state


func _ready():
#	add_sketch("/home/ruthgerd/Documents/demo/demo.ino")
    pass

func add_board(sketch_id: int) -> Result:
    var sketch = Track.container_index(self._sketch_state.sketches, sketch_id)

    var board = Board.new()
    
    _boards.append({"board": board, "requests": []})
    
    var state_obj = {
        "attached_sketch": sketch, 
        "state": BOARD_UNAVAILABLE,
        "board_log": "",
    }
    boards.push(state_obj)
    
    var index = boards.value().find(state_obj)
    
    return Result.new().set_ok(index)

func start_board(board_id: int):
    _boards[board_id].requests = []
    
    var sketch_id = boards.value_at(board_id).attached_sketch.value()
    var sketch_state = _sketch_state.sketches.value_at(sketch_id)
    
    # TODO this needs to be done last as we STAGE the board publically which could invoke side effects
    var sketch: Sketch = sketch_state.sketch
    
    if (sketch == null || !sketch.compiled):
        return Result.new().set_err("sketch not compiled or existing")
    
    # if the sketch is not compiled then we just fail
    
    var registry: ManifestRegistry = sketch_state.registry
    
    boards.mutate_at(board_id, func(v):
        v.state = BOARD_STAGING
        return v
    )
    
    # people request hardware
    var board_internal: Dictionary = _boards[board_id]
    var board: Board = board_internal.board
    
    var config := BoardConfig.new()
    
    var give_out := []
    for request in board_internal.requests:
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
        pass
    
    var devices = config.board_devices
    var res: Result = board.initialize(registry, config)
    assert(res.is_ok())
    
    if res.is_err():
        print(res.get_value())
        return res
    
    var view = board.get_view()
    for j in _boards[board_id].requests.size():
        var collect = []
        
        var obj: HardwareBase = _boards[board_id].requests[j]
        
        for z in give_out[j]:
            collect.append(z.call(board.get_view()))
        obj._rec = collect
        
        add_child(obj)
    
    _boards[board_id].requests = []

    var start_res = board.start(sketch)

    if start_res.is_err():
        print("Deleting hardware due to failure")
        for child in _boards[board_id].requests:
            remove_child(child)
            child.queue_free()

    boards.mutate_at(board_id, func(v):
        if start_res.is_err():
            printerr("Failed to start board: ", start_res.get_value())
            v.board = BOARD_UNAVAILABLE
        else:
            v.board = BOARD_RUNNING
        return v
    )
    
    return start_res

func _process(delta):
    for i in _boards.size():
        var bd = _boards[i]
        var res = bd.board.poll()
        var log = bd.board.log_reader().read()
        if log != "" && log != null:
            print("board log: ", log)
        if res.is_err():
            boards.mutate_at(i, func(v):
                v.state = BOARD_CRASHED
                return v
            )
            print("board error!: ", res.get_value)
            assert(false)

func request_hardware(i: int, node: HardwareBase):
    assert(boards.value_at(i).state == BOARD_STAGING)
    _boards[i].requests.append(node)


func toggle_board_suspend(i: int):
    var board_state: Dictionary = boards.value_at(i)
    var board: Board = _boards[i].board
    
    match board_state.state:
        BOARD_RUNNING:
            var res: Result = board.suspend()
            if res.is_err():
                printerr("Failed to suspend board: ", res.get_value())
                return
            boards.mutate_at(i, func(v):
                v.state = BOARD_SUSPENDED
                return v
            )
        BOARD_SUSPENDED:
            var res: Result = board.resume()
            if res.is_err():
                printerr("Failed to resume board: ", res.get_value())
                return
            boards.mutate_at(i, func(v):
                v.state = BOARD_RUNNING
                return v
            )
        _: pass

func stop_board(board_id: int):
    pass
    

    
