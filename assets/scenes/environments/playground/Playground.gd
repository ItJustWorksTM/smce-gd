extends Node3D


func get_spawnpoint(hint: String) -> Transform3D:
    
    var ret = $Position3D.transform
    
    ret.origin += Vector3(randf_range(5.0,100.0), randf_range(0.0,20.0), randf_range(0,50.0))
    
    ret.basis = ret.basis.rotated(Vector3.FORWARD, randf_range(0, PI))
    
    return ret
