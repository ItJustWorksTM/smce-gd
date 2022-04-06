class_name Future
extends Object

signal finished

var thread: Thread

func _work(cb):
    var value = await cb.call()
    thread.call_deferred("wait_to_finish")
    call_deferred("emit_signal","finished", value)
    call_deferred("free")

func start(cb: Callable):
    thread = Thread.new()
    thread.start(self._work, cb)
    return self.finished
