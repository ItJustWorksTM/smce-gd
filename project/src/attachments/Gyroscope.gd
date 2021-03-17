extends Node

export(NodePath) var node = ""
onready var _track_node: Spatial = get_node_or_null(node)

export(int, 256) var pin = 0;


var view = null setget set_view

var _y_rotate: float = 0

func set_view(_view) -> void:
	if ! _view:
		return
	
	view = _view
	view.connect("invalidated", self, "set_physics_process", [false])
	set_physics_process(view.is_valid())


func _ready() -> void:
	set_physics_process(false)


func _physics_process(delta) -> void:
	if ! node:
		set_physics_process(false)
	
	_y_rotate = _track_node.rotation_degrees.y + 180
	view.write_analog_pin(pin, int(_y_rotate))
	
	if ! view.is_valid():
		set_physics_process(false)


func name() -> String:
	return "Gyroscope"


func visualize() -> Control:
	var visualizer = NodeVisualizer.new()
	visualizer.display_node(self, "visualize_content")
	return visualizer


func visualize_content() -> String:
	return "   Rotation: %.3f degrees" % (_y_rotate - 180)
