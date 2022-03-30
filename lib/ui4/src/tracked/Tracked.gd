class_name Tracked

# TODO: runtime mut check?

enum { SET, MODIFIED, INSERTED, REMOVED, MOVED }

const oops = ["SET", "MODIFIED", "INSERTED", "REMOVED", "MOVED"]

signal changed(what: int, how: Variant)

func _emit_change(what: int, how: Variant):
#    if !self.changed.get_connections().is_empty():
#        print()
#        print("%s::_emit_change(%s, %s)" % [self, oops[what], how])
#        for connection in self.changed.get_connections():
#            print("^^^ emiting to: ", connection.callable.get_object())
#        print()
    
    changed.emit(what, how)

func emit_set():
    _emit_change(SET, 0)

func type():
    return typeof(self.value())

func value():
    assert(false, "what")

func change(_v: Variant):
    assert(false, "view only")

func mutate(cb: Callable):
    self.change(cb.call(self.value()))

func _arr_to_string(arr):
    return ("[" + str(arr[0] if arr.size() >= 1 else "") + str(" .. (+%d elements) .. " % (arr.size() -2) if arr.size() >= 3 else "") + str(arr[-1] if arr.size() >= 2 else "") + "]")

func _to_string():
    var value = self.value()
    
    return "%s(%s)" % [_get_class(), _arr_to_string(value) if value is Array else str(value)]

func _get_class(): return "Tracked"
