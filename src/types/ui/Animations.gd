class_name Animations

static func anim_open(obj: Control) -> Tween:
    var tween = TweenTemplate.new()
    tween.lerp_prop_relative(obj, "rect_scale:y", 0, 0.3, Tween.TRANS_SINE)
    tween.lerp_prop_relative(obj, "visible", false, 0.3)
    tween.lerp_prop_relative(obj, "modulate:a", 0, 0.15)
    var ret = tween.create()
    obj.add_child(ret)
    return ret

static func anim_close(obj: Control) -> Tween:
    var tween = TweenTemplate.new()
    tween.lerp_prop_relative(obj, "rect_scale:y", 1, 0.2, Tween.TRANS_SINE)
    tween.lerp_prop_relative(obj, "visible", true, 0)
    tween.lerp_prop_relative(obj, "modulate:a", 1, 0.10)
    var ret = tween.create()
    obj.add_child(ret)
    return ret

