class_name CamCtl
extends Node

signal cam_locked
signal cam_freed

var locked_cam = null
var free_cam = null
var interp_cam = null

var locked = false

func lock_cam(node: Spatial) -> void:
	if ! node || ! node.is_inside_tree():
		return
	interp_cam.set_target(locked_cam)
	locked_cam.set_target(node)
	free_cam.set_disabled(true)
	emit_signal("cam_locked", node)
	locked = node
	node.connect("tree_exiting", self, "_on_free", [node])


func free_cam() -> void:
	interp_cam.set_target(free_cam)
	free_cam.set_disabled(false)
	free_cam.transform = locked_cam.transform
	emit_signal("cam_freed")
	locked = null


func _on_free(node) -> void:
	if node == locked:
		free_cam()
