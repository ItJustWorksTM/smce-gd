class_name CamCtl
extends Node

signal cam_locked
signal cam_freed

var locked_cam: Spatial = null
var free_cam: Spatial = null
var interp_cam: Spatial = null

var locked = null

func lock_cam(node: Spatial) -> void:
	if ! is_instance_valid(node) || ! node.is_inside_tree():
		return
	interp_cam.set_target(locked_cam)
	locked_cam.set_target(node)
	free_cam.set_disabled(true)
	emit_signal("cam_locked", node)
	locked = node
	if ! node.is_connected("tree_exiting", self, "_on_free"):
		node.connect("tree_exiting", self, "_on_free", [node])


func free_cam() -> void:
	interp_cam.set_target(free_cam)
	free_cam.set_disabled(false)
	free_cam.transform = locked_cam.transform
	emit_signal("cam_freed")
	if is_instance_valid(locked):
		locked.disconnect("tree_exiting", self, "_on_free")
	locked = null


func set_cam_position(transform: Transform = Transform()) -> void:
	free_cam()
	locked_cam.global_transform = transform
	free_cam.global_transform = transform
	interp_cam.global_transform = transform


func _on_free(node) -> void:
	if node == locked:
		free_cam()
