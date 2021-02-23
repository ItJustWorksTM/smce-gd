extends VBoxContainer

func add_notification(node: Control, timeout: float = -1) -> void:
	add_child(node)
	node.modulate.a = 0
	
	
	var tween: Tween = Tween.new()
	add_child(tween)
	tween.interpolate_property(node, "modulate:a", node.modulate.a, 1, 0.3, Tween.TRANS_CUBIC)
	tween.start()
	yield(tween,"tween_all_completed")
	tween.queue_free()
	
	
	if node.has_signal("stop_notify"):
		node.connect("stop_notify", self, "_remove_notification", [node])
	if timeout >= 0:
		yield(get_tree().create_timer(timeout), "timeout")
		_remove_notification(node)

func _remove_notification(node: Control) -> void:
	if ! node:
		return
	node.disconnect("stop_notify", self, "_remove_notification")
	var tween: Tween = Tween.new()
	add_child(tween)
	tween.interpolate_property(node, "modulate:a", node.modulate.a, 0, 0.3, Tween.TRANS_CUBIC)
	tween.start()
	yield(tween,"tween_all_completed")
	node.queue_free()
	tween.queue_free()
