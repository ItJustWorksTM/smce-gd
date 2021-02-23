extends Control

onready var _wrapped: FileDialog = $FileDialog

enum dialog_type { SAVE, OPEN }
export (dialog_type) var mode = dialog_type.OPEN


func _ready():
	# Trigger file refresh
	_wrapped.popup()
	_wrapped.hide()


func _process(_delta: float) -> void:
	_wrapped.rect_size = rect_size - Vector2(0, 12)
	_wrapped.rect_position = rect_position + Vector2(0, 12)
	_wrapped.rect_scale = rect_scale
	_wrapped.modulate = modulate
	_wrapped.rect_pivot_offset = rect_pivot_offset
	_wrapped.visible = visible
	if mode == dialog_type.SAVE:
		_wrapped.mode = FileDialog.MODE_SAVE_FILE
	elif mode == dialog_type.OPEN:
		_wrapped.mode = FileDialog.MODE_OPEN_FILE


func connect(sig_name: String, object: Object, func_name: String, bind: Array = [], idx: int = 0) -> int:
	return _wrapped.connect(sig_name, object, func_name, bind, idx)
