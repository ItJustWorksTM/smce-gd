class_name BoardState extends Node

enum { BOARD_RUNNING, BOARD_CRASHED, BOARD_SUSPENDED, BOARD_STAGING, BOARD_UNAVAILABLE }

class StateObj:
    var attached_sketch: Tracked
    var state: int = BOARD_UNAVAILABLE
    var request_fn: Callable
    var board_log: String = ""

var boards := Cx.array([])

var add_board := func(sketch_id: int): pass
var start_board := func(board_id: int): pass
var request_hardware := func(i: int, node: HardwareBase): pass
var suspend_board := func(i: int): pass
var resume_board := func(i: int): pass
var stop_board := func(i: int): pass
