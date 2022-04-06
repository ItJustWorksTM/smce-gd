class_name RayCastWheel extends Node3D

# Spring parameters
var rest_length: float = 0.4
var spring_travel: float = 0.25
var wheel_radius: float = 0.2
var spring_stiffness: float = 600
var damper_stiffness: float = 30
# Motor parameters
var motor_strength: float = 0.0

var max_length: float:
    get: return rest_length + spring_travel
var min_length: float:
    get: return rest_length - spring_travel
var full_length: float:
    get: return wheel_radius + max_length
var spring_length: float
var spring_force: float

var last_length: float

@onready
var vehicle := get_parent() as RayCastVehicle

@export
var easthetic_wheel_path: NodePath
var easthetic_wheel: Node3D

# TODO: Cast a shape instead
var ray := PhysicsRayQueryParameters3D.new()
func _cast_ray():
    var world3d := get_world_3d().direct_space_state
    ray.from = global_transform.origin
    ray.to = to_global(Vector3(0,-self.full_length, 0))

    var result: Dictionary = world3d.intersect_ray(ray)
    if result.size() > 0:
        result.hit_distance = ray.from.distance_to(result.position)
    return result

func _ready():
    vehicle.wheels += [self]
    easthetic_wheel = get_node(easthetic_wheel_path)
    ray.exclude = [vehicle.get_rid()]

func _physics_process(delta: float) -> void:
    var result = _cast_ray()
    
    var wheel_position: Vector3
    
    if result.size() > 0:
        wheel_position = result.position + Vector3(0,wheel_radius,0)
        last_length = spring_length
        var hit_distance: float = result.hit_distance
        
        spring_length = hit_distance - wheel_radius
        spring_length = clamp(spring_length, min_length, max_length)
        
        var spring_velocity := (last_length - spring_length) / delta
        
        var spring_force := spring_stiffness * (rest_length - spring_length)
        var damper_force := damper_stiffness * spring_velocity
        
        var suspension_force := (spring_force + damper_force) * (global_transform.basis * Vector3.UP)
        
        var force_position: Vector3 = result.position - vehicle.global_transform.origin
        
        var wheel_velocity := vehicle.get_point_velocity(result.position) * global_transform.basis
        var f_z := motor_strength * spring_force
        var f_x := wheel_velocity.x * spring_force * 0.5
        
        if motor_strength == 0 && wheel_velocity.z != 0:
            f_z = (wheel_velocity.z / abs(wheel_velocity.z)) * spring_force
        
        var forward_force: Vector3 = f_z * (global_transform.basis * Vector3.FORWARD)
        var side_force: Vector3 = f_x * (global_transform.basis * -Vector3.RIGHT)
        
        var total_force := suspension_force + forward_force + side_force
        vehicle.apply_force(total_force, force_position)
#        DebugCanvas.add_draw(vehicle.global_transform.origin + force_position, vehicle.global_transform.origin + force_position + total_force / 100)
#        DebugCanvas.add_draw(global_transform.origin, result.position, Color.RED)    
    else:
        wheel_position = global_transform.origin + Vector3(0,-last_length,0) * global_transform.basis
    
    if is_instance_valid(easthetic_wheel):
        easthetic_wheel.global_transform.origin = wheel_position
