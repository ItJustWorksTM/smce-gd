class_name TweenTemplate

class OneshotTween:
    extends Tween

    func _init():
        var __ = connect("tween_all_completed", self, "queue_free")

var _interpolated_props := []

func lerp_prop_relative(obj: Object, property: NodePath, final_val, duration: float, trans_type: int = 0, ease_type: int = 2, delay: float = 0):
    _interpolated_props.append({
        "obj": obj, "property": property, "final_val": final_val, "duration": duration, "trans_type": trans_type, "ease_type": ease_type, "delay": delay
    })
    
func create() -> OneshotTween:
    var tween := OneshotTween.new()

    for ent in _interpolated_props:
        var res = tween.interpolate_property(ent.obj, ent.property, ent.obj.get_indexed(ent.property), ent.final_val, ent.duration, ent.trans_type, ent.ease_type, ent.delay)
        assert(res)
    
    return tween

