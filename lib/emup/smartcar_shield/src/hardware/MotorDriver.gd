class_name MotorDriver extends Node

var vehicle: RayCastVehicle

var drive_left_wheels: bool = false
var drive_right_wheels: bool = false

var input: BrushedMotor

func _physics_process(_delta: float) -> void:
    if drive_left_wheels:
        for wheel in vehicle.left_wheels:
            wheel.motor_strength = input.speed
    if drive_right_wheels:
        for wheel in vehicle.right_wheels:
            wheel.motor_strength = input.speed
    
