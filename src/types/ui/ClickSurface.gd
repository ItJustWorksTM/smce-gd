
class_name ClickSurface
extends Control

signal pressed()

var disabled = false setget set_disabled, get_disabled

func set_disabled(s):
    disabled = s
    mouse_filter = Control.MOUSE_FILTER_STOP if !disabled else Control.MOUSE_FILTER_IGNORE

func get_disabled(): return disabled

func _gui_input(event):
    if event.is_action_pressed("mouse_left"):
        emit_signal("pressed")
