class_name BoardImpl
extends Node

static func board_impl(sketch_state: SketchState): return func(c: Ctx):
    c.inherits(Node)
    
    var state: BoardState = c.register_state(BoardState, BoardState.new())
    
    var internal := Cx.array([])
    var empty_internal = func(): return { board = Board.new(), hardware = [] }
    
    var get_board = func(at): return internal.value_at(at).board
    
    state.add_board = func(sketch_id: int) -> Result:
        internal.push(empty_internal.call())
        
        var sketch = Cx.container_index(sketch_state.sketches, sketch_id)
        var state_obj = BoardState.StateObj.new()
        state_obj.attached_sketch = sketch
        state.boards.push(state_obj)
        
        return Result.new().set_ok(state.boards.value().find(state_obj))

    state.start_board = func(board_id: int):
        if state.boards.value_at(board_id).state != BoardState.BOARD_UNAVAILABLE:
            return Result.new().set_err("Board already active")
        
        var requests = []
    
        state.boards.mutate_at(board_id, func(v):
            v.state = BoardState.BOARD_STAGING
            v.request_fn = func(node: HardwareBase):
                requests.append(node)
            return v
        )
        
        var board_internal: Dictionary = internal.value_at(board_id)
        var board: Board = board_internal.board
        
        var sketch_id: int = state.boards.value_at(board_id).attached_sketch.value()
        var sketch_s = sketch_state.sketches.value_at(sketch_id)
        
        var sketch: Sketch = sketch_s.sketch
        var registry: ManifestRegistry = sketch_s.registry
        
        var infer = infer_config(requests)
        var config: BoardConfig = infer.config
        var spread_fn: Callable = infer.spread_fn
        
        var res: Result = board.initialize(registry, config)
        
        
        if res.is_err():
            for r in requests: r.free()
            
            internal.change_at(board_id, empty_internal.call())            
            state.boards.mutate_at(board_id, func(v):
                v.state = BoardState.BOARD_UNAVAILABLE
                return v
            )
            
            return res
        
        internal.mutate_at(board_id, func(v):
            spread_fn.call(board.get_view())
            v.hardware = requests
            return v
        )

        var start_res = board.start(sketch)

        if start_res.is_err():
            internal.change_at(board_id, empty_internal.call())

        state.boards.mutate_at(board_id, func(v):
            v.state = BoardState.BOARD_RUNNING if start_res.is_ok() else BoardState.BOARD_UNAVAILABLE
            v.board_log = ""            
            return v
        )
        
        return start_res

    state.suspend_board = func(i: int):
        if get_board.call(i).suspend().is_ok():
            state.boards.mutate_at(i, func(v):
                v.state = BoardState.BOARD_SUSPENDED
                return v
            )

    state.resume_board = func(i: int):
        if get_board.call(i).resume().is_ok():
            state.boards.mutate_at(i, func(v):
                v.state = BoardState.BOARD_RUNNING
                return v
            )

    state.stop_board = func(i: int):
        if get_board.call(i).stop().is_ok():
            internal.change_at(i, empty_internal.call())
            state.boards.mutate_at(i, func(v):
                v.state = BoardState.BOARD_UNAVAILABLE
                return v
            )

    c.child_opt(Cx.map_children(internal, func(i, obj): return func(c: Ctx):
        c.inherits(Node)
        c.child_opt(Cx.map_child(obj, func(obj): return func(c: Ctx):
            if obj == null: return
            c.inherits(BoardPoller, [obj.board])
            c.on("log", func(log):
                state.boards.mutate_at(i.value(), func(v):
                    v.board_log += log
                    return v
                )
            )
            c.on("crash", func(res):
                internal.mutate_at(i, func(v):
                    v.board = Board.new()
                    v.hardware = []
                )
                state.boards.mutate_at(i.value(), func(v):
                    v.state = BoardState.BOARD_CRASHED
                    return v
                )
            )
            for hw in obj.hardware:
                c.child(hw)
        ))
    ))

static func infer_config(requests):
    var config := BoardConfig.new()
    var give_out := []
    for request in requests:
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
                if bd == null: 
                    config.board_devices.append(demand)
                else:
                    bd.count += 1
                    size = bd.count -1
                getters.append(func(view: BoardView):
                    return view.board_devices[demand.device_name][size])
            elif demand is SecureDigitalStorageConfig:
                if Fn.find_value(config.sd_cards, demand) == null:
                    config.sd_cards.append(demand)
                getters.append(func(view: BoardView): return view.sd_cards[demand.cspin])
        
        give_out.append(func(view: BoardView):
            for getter in getters:
                request._rec.append(getter.call(view))
        )
    
    var chi = func(view: BoardView):
        for g in give_out:
            g.call(view)
    
    return { config = config, spread_fn = chi }
