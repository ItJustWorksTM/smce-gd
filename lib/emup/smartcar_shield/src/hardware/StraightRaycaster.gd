class_name StraightRaycaster
extends RayCast3D

var output: GP2

func _process(_delta: float) -> void:
    var dist: float = 0.0
    if is_colliding():
        var hit = get_collision_point()
        dist =  global_transform.origin.distance_to(hit)
    
    output.distance = dist
