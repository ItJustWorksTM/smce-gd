class_name Inner
extends Observable

var _observable: Observable

func _init(ob: Observable) -> void:
	self._observable = ob
	
	ob.changed.connect(self._on_inner_change)
	_reconnect()

func _reconnect():
	for l in get_incoming_connections():
		if l.callable.get_object() == self && l.callable.get_method() == "emit_change":
			l["signal"].disconnect(l.callable)
	self._observable.value.changed.connect(self.emit_change)

func _on_inner_change():
	emit_change()
	_reconnect()

func get_value() -> Variant:
	return self._observable.value.value
