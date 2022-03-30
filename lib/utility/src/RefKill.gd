class_name RefKill

var _obj: Object = null

func _init(obj: Object):
    self._obj = obj

func _notification(what):
    if what == NOTIFICATION_PREDELETE:
        if is_instance_valid(_obj):
            _obj.free()
