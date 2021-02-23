class_name AnalogRaycastGD
extends RayCast

export(int, 100) var pin = 1
var view = null setget set_view

var distance: float = 0

func set_view(_view: Node) -> void:
	if ! _view:
		_on_view_invalidated()
		return
	
	view = _view
	
	view.connect("invalidated", self, "_on_view_invalidated")
	
	set_physics_process(true)


func _on_view_invalidated() -> void:
	view = null
	set_physics_process(false)


func _ready() -> void:
	set_physics_process(false)


func _physics_process(_delta: float):
	if ! is_colliding():
		return

	var pos = global_transform.origin
	var hit = get_collision_point()
	var dist = pos.distance_to(hit)
	
	distance = dist
	view.write_analog_pin(1, int(dist * 100))

func name() -> String:
	return "AnalogRaycast"

func visualize() -> Control:
	var visualizer = NodeVisualizer.new()
	visualizer.display_node(self, "visualize_content")
	return visualizer

func visualize_content() -> String:
	return "   Pin: %d\n   Distance: %.3fm" % [pin, distance]
