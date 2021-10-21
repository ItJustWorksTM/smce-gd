class_name Async

class _Async:
    var thread: Thread
    var lambda: FuncRef
    var promise

    func _init(obj, method, args):
        var __ = reference()
        thread = Thread.new()
        lambda = funcref(obj, method)
        promise = Promise.new()
        var res = thread.start(self, "_run", args)
        assert(res == OK)

    func _run(args):
        promise.set_value(lambda.call_funcv(args))
        call_deferred("_delete")

    func _delete():
        thread.wait_to_finish()
        var __ = unreference()

static func run(obj: Object, method: String, args: Array):
    return _Async.new(obj, method, args).promise.get_future()
