#
#  ControllableCamera.gd
#  Copyright 2021 ItJustWorksTM
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#

extends Camera

#default speed
export(float) var speed = 5.0;
export (NodePath) var target =  NodePath("") setget set_target;

func set_target(p_target: Spatial) -> void:
    ERR_FAIL_NULL(p_target);
	target = get_path_to(p_target);

func _set_target(p_target: Object) -> void:
    ERR_FAIL_NULL(p_target);
	set_target(Object::cast_to<Spatial>(p_target));

func set_speed(p_speed: float) -> void:
    speed = p_speed;

func get_speed() -> float:
    return speed;

func _physics_process(delta) -> void:
        if !enabled:
                break;
	    if ! target:
	            return;
	    #supposedly it will be casted to spatial
        var node = get_node(target)
        if !node:
                break;
	    var target_xform = node.get_global_transform();
	    var local_transform = get_global_transform();
	    #adjusted delta
	    var new_delta = speed * delta;
	    local_transform = local_transform.interpolate_with(target_xform, new_delta)
        	set_global_transform(local_transform)
        	var cam := node as Camera
        	if (cam):
        		if (cam.get_projection() == get_projection()):
        		    new_near = lerp(get_znear(), cam.get_znear(), new_delta);
        		    new_far = lerp(get_zfar(), cam.get_zfar(), delta);
        			if (cam.get_projection() == PROJECTION_ORTHOGONAL):
        				var size = lerp(get_size(), cam.get_size(), new_delta)
        				set_orthogonal(size, near, far)
        			else:
        				var fov = lerp(get_fov(), cam.get_fov(), new_delta)
        				set_perspective(fov, near, far)