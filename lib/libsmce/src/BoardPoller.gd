class_name BoardPoller
extends Node

var board: Board

signal log
signal crash

func _init(board):
    self.board = board

func _process(_delta: float) -> void:
    if !board.is_active(): return
    var res = board.poll()
    
    var log = self.board.log_reader().read()
    
    if log != null && log != "":
        self.log.emit(log)
    
    if res.is_err():
        self.crash.emit(res.get_value())
    
