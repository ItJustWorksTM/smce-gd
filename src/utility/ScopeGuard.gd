class_name ScopeGuard

var cb: Callable

func _init(cb: Callable):
	self.cb = cb

func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		cb.call()
