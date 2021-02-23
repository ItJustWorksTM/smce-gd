class_name NodeVisualizer
extends Label

var _node: Node = null
var _visual_func: String = ""

func display_node(node: Node, visual_func: String) -> bool:
	if ! node || ! node.has_method(visual_func):
		return false
	_node = node
	_visual_func = visual_func
	
	return true

func _process(_delta: float) -> void:
	if ! _node:
		return
	
	text = _node.call(_visual_func)
