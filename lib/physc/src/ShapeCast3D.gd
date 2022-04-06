@tool
class_name ShapeCast3D extends Node3D

@export
var shape := Shape3D

@export
var target_position := Vector3(0,0,0)

# https://github.com/godotengine/godot/pull/56470/files

func _physics_process(delta):
    var w3d: = get_world_3d();
    var dss: = w3d.direct_space_state

    var gt = global_transform

    var params = PhysicsShapeQueryParameters3D.new()
    params.shape = shape;
    params.transform = gt;
    params.motion = target_position;

    if (target_position != Vector3()):
        var res = dss.cast_motion(params);
        if (res[0] < 1.0):
            var new_orig = (gt.origin + params.motion * (res[1] + 0.00001));
            print(gt.origin.distance_to(new_orig))
            gt.origin = new_orig
            params.transform = gt;

    params.motion = Vector3();

    var result := dss.get_rest_info(params);
    var collided = !result.is_empty();
#    if result.size() > 0:
#        print(result)
