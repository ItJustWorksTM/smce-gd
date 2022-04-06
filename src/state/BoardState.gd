class_name BoardState extends Node

enum { BOARD_RUNNING, BOARD_CRASHED, BOARD_SUSPENDED, BOARD_STAGING, BOARD_UNAVAILABLE }

class StateObj:
    var attached_sketch: Tracked
    var state: int = BOARD_UNAVAILABLE
    var request_fn: Callable
    var board_log: String = ""

var boards := Cx.array([])

var c: Ctx
var sketch_state: SketchState


func get_board(at): return self.boards.value_at(at).board

func add_board(sketch_id: int):
    var man = sketch_state.sketches.value_at(sketch_id)
    
    var z = Cx.container_value(sketch_state.sketches, sketch_id)
    self.boards.push({ 
        sketch = Cx.inner(Cx.lens(z, "sketch")),
        info = Cx.inner(Cx.lens(z, "info")),
        board = Cx.value({ 
            handle = null,
            state = BoardState.BOARD_UNAVAILABLE,
            log = "",
            hardware = {}
        })
    })

func start_board(board_id: int):
    var thing = self.boards.value_at(board_id)
    
    var value = thing.info.value()
    var hardware = value.req_hardware

    var requests = {}
    for key in hardware.keys():
        var label = key
        var props: Dictionary = hardware[key].duplicate()
        var type = props.type

        props.erase("type")

        if type in value.hardware:
            var object = value.hardware[type].script.new()

            for prop in props.keys():
                object.set(prop, props[prop])

            requests[key] = object
        else:
            assert(false, "nooo")

    
    var infer = infer_config(requests.values())
    var config: BoardConfig = infer.config
    var spread_fn: Callable = infer.spread_fn
    
    var board = Board.new()
    var res: Result = board.initialize(value.registry, config)
    
    if res.is_err():
        for r in requests: r.free()
        assert(false)
        return res
    
    spread_fn.call(board.get_view())
    
    
    var pro = thing.board
    c.child(func(c: Ctx):
        c.inherits(BoardPoller, [board])
        
        for n in requests.values():
            c.child(n)
        
        c.on("log", func(log):
            pro.mutate(func(v):
                v.log += log
                return v
            )
        )
        
        c.on("crash", func(res):
            pro.mutate(func(v):
                v.board = null
                v.state = BoardState.BOARD_CRASHED
                v.hardware = {}
                return v
            )
        )

        c.on(pro.changed, func(w,h):
            if pro.value().handle == null:
                c.node().get_parent().remove_child(c.node())
                c.node().queue_free()
        )
    )
    
    var sketch = thing.sketch.value().handle
    var start_res = board.start(sketch)

    if start_res.is_err():
        pass
        assert(false)

    thing.board.mutate(func(v):
        v.handle = board
        v.state = BoardState.BOARD_RUNNING if start_res.is_ok() else BoardState.BOARD_UNAVAILABLE
        v.board_log = ""     
        v.hardware = requests       
        return v
    )
    
    return start_res

func suspend_board(i: int):
    var board = get_board.call(i)
    if board.value().handle.suspend().is_ok():
        board.mutate(func(v):
            v.state = BoardState.BOARD_SUSPENDED
            return v
        )

func resume_board(i: int):
    var board = get_board.call(i)
    if board.value().handle.resume().is_ok():
        board.mutate(func(v):
            v.state = BoardState.BOARD_RUNNING
            return v
        )

func stop_board(i: int):
    var board = get_board.call(i)
    if board.value().handle.stop().is_ok():
        board.mutate(func(v):
            v.handle = null
            v.state = BoardState.BOARD_UNAVAILABLE
            v.hardware = {}
            return v
        )

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

func _init(sketch_state: SketchState) -> void:
    self.sketch_state = sketch_state

func _ctx_init(c: Ctx):
    c.register_as_state()
    self.c = c
