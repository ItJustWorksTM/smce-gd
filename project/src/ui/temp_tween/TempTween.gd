class_name TempTween
extends Tween

func _init() -> void:
	connect("tween_all_completed", self, "queue_free")
