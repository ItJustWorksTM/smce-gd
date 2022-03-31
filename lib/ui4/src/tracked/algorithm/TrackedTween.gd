class_name TrackedTween extends TrackedValue

var _tracked: Tracked
var _tween: Tween

var _speed: float
var _trans: Tween.TransitionType

func _init(ob: Tracked, speed: float, trans: Tween.TransitionType = 0) -> void:
    self._tracked = ob
    self._speed = speed
    self._trans = trans
    self._value = ob.value()
    
    ob.changed.connect(self._update)
    
    _update(0,0)

func _update(w,h):
    if is_instance_valid(_tween):
        _tween.stop()
        _tween = null
    elif self.value() == self._tracked.value():
        return
    
    var tree := Engine.get_main_loop() as SceneTree
    assert(tree)
    
    var new_target = self._tracked.value()

    _tween = tree.create_tween()
    _tween.tween_property(self, "_value", new_target, self._speed)
    _tween.play()


func get_class(): return "TrackedTween"
