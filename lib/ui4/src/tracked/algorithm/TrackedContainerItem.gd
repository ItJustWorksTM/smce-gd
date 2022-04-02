class_name TrackedContainerItem extends TrackedValue

var _ob: TrackedContainer

func _init(ob: TrackedContainer, at):
    self._ob = ob
    self._value = at
    ob.changed.connect(self._update)

func _update(w,h):
    match w:
        SET:
            self._value = null
            print("TRACKED INDEX DIED")
        MOVED:
            if self._value == h[0]:
#                print("index modified, originally at %d, pair: %s" % [self.__value,h])
                self._value = h[1]
        REMOVED:
            if self._value == h:
#                print("index removed")
                self._value = null
                print("TRACKED INDEX DIED 2")
        MODIFIED:
            emit_set() # TODO wooops

func _get_class(): return "TrackedContainerIndex"
