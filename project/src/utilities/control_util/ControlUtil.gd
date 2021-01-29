class_name ControlUtil

static func toggle_window(show: bool, node: Control) -> void:
	# TODO: set proper default values at _ready
	node.visible = true

	var tween: Tween = Tween.new()
	node.add_child(tween)
	tween.interpolate_property(
		node, "rect_scale:y", node.rect_scale.y, int(show), 0.15, Tween.TRANS_SINE
	)
	tween.interpolate_property(node, "modulate:a", node.modulate.a, int(show), 0.12)
	tween.start()
	yield(tween, "tween_all_completed")
	node.remove_child(tween)
	tween.queue_free()
