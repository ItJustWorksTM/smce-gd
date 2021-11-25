class_name RAII
var lol = Reference.new()
func _init():
    lol.add_user_signal("deleted")
func _notification(what):
    if what == NOTIFICATION_PREDELETE:
        lol.emit_signal("deleted")

static func on_death(obj, target, method, binds = []):
    if !obj.has_meta("__RAII"):
        obj.set_meta("__RAII", load("res://src/util/RAII.gd").new())
    obj.get_meta("__RAII").lol.connect("deleted", target, method, binds)
