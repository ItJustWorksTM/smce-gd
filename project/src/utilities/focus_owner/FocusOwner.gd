extends Control


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("mouse_left"):
		FocusOwner.release_focus()

func has_focus() -> bool:
	return get_focus_owner() != null

func release_focus() -> void:
	if has_focus():
		get_focus_owner().release_focus()
