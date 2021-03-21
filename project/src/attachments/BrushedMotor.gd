class_name BrushedMotorGD
extends Node

export(int, 100) var forward_pin = 0
export(int, 100) var backward_pin = 0
export(int, 100) var enable_pin = 0

var view = null setget set_view

var speed: float = 0
var direction: int = 0

func set_view(_view: Node) -> void:
	if ! _view:
		return
	
	view = _view
	view.connect("validated", self, "set_physics_process", [true])
	set_physics_process(view.is_valid())


func set_pins(ebl: int, fwd: int, bwd: int) -> void:
	enable_pin = ebl
	forward_pin = fwd
	backward_pin = bwd


func get_speed() -> float:
	return speed


func _ready() -> void:
	set_physics_process(false)


func _physics_process(_delta: float) -> void:
	var abs_speed = view.read_analog_pin(enable_pin)
	var forward = view.read_digital_pin(forward_pin)
	var backward = view.read_digital_pin(backward_pin)
	direction = int(forward) - int(backward)
	
	speed = (abs_speed / 255.0) * direction
	if ! view.is_valid():
		set_physics_process(false)


func name() -> String:
	return "BrushedMotor"


func visualize() -> Control:
	var visualizer = NodeVisualizer.new()
	visualizer.display_node(self, "visualize_content")
	return visualizer


var vs_dir: Array = ["None", "Forward", "Backward"]
func visualize_content() -> String:
	return "   Pins: %d,%d,%d\n   Throttle: %s \n   Direction: %s" % [forward_pin, backward_pin, enable_pin, str(int(abs(speed) * 100)) + '%',  vs_dir[direction]]
