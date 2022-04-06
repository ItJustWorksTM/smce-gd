class_name RayCastVehicle extends RigidDynamicBody3D

var wheels: Array[RayCastWheel] = []
var left_wheels: Array[RayCastWheel]:
    get:
        var ret = []; for w in wheels: if w.transform.origin.x > 0: ret.push_back(w as RayCastWheel)
        return ret
var right_wheels: Array[RayCastWheel]:
    get:
        var ret = []
        for wheel in wheels: if wheel.transform.origin.x < 0: ret.push_back(wheel as RayCastWheel)
        return ret

func get_point_velocity(point: Vector3) -> Vector3:
    return linear_velocity + angular_velocity.cross(point - global_transform.origin)

func _physics_process(_delta):
    var fw = Input.get_axis("ui_down", "ui_up")
    
    for wheel in left_wheels:
        wheel.motor_strength = fw * int(!Input.is_action_pressed("ui_right"))
    for wheel in right_wheels:
        wheel.motor_strength = fw * int(!Input.is_action_pressed("ui_left"))

