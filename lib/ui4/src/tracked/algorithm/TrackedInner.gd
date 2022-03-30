class_name TrackedInner
extends Tracked

var _tracked: Tracked

func _init(tracked: Tracked) -> void:
    self._tracked = tracked
    
    tracked.changed.connect(self._on_outer_change)
    _reconnect()

func _reconnect():
    for l in get_incoming_connections():
        if l.callable.get_object() == self && l.callable.get_method() == "_on_inner_change":
            l["signal"].disconnect(l.callable)
    self._tracked.value().changed.connect(self._on_inner_change)

func _on_outer_change(_w,_h):
    emit_set()
    _reconnect()

func _on_inner_change(_w, _h):
    emit_set()

func value() -> Variant:
    return self._tracked.value().value()

func _class_name(): return "TrackedInner"
