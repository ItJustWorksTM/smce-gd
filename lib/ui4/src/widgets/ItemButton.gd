@tool
class_name ItemButton
extends Container

signal activated()
signal selected()

var _active: bool = false
var _hovering: bool = false

@export var active: bool:
	set(v):
		_active = v
		update()
	get: return _active

func _gui_input(event: InputEvent):
	if event is InputEventMouseButton && event.pressed && event.button_index == MOUSE_BUTTON_LEFT:
		active = true
		if event.double_click:
			self.activated.emit()
		else:
			self.selected.emit()
	
	if event.is_action_pressed("ui_accept"):
		self.selected.emit()
		self.activated.emit()
		active = true

func _init():
	set_mouse_filter(MOUSE_FILTER_STOP);
	focus_mode = Control.FOCUS_ALL

var style_normal: StyleBox:
	get: return get_theme_stylebox("normal", "ItemButton")

var style_focused: StyleBox:
	get: return get_theme_stylebox("focused", "ItemButton")

var style_selected: StyleBox:
	get: return get_theme_stylebox("selected", "ItemButton")

var style_hovered: StyleBox:
	get: return get_theme_stylebox("hover", "ItemButton")

var style: StyleBox:
	get:
		return style_hovered if _hovering else style_normal if !active else style_selected

func _get_minimum_size() -> Vector2:
	var ms = Vector2.ZERO
	for child in get_children(true):
		if child as Control == null || !child.is_visible_in_tree() || child.is_set_as_top_level():
			continue
		
		var minsize = child.get_combined_minimum_size()
		ms.x = max(minsize.x, ms.x)
		ms.y = max(minsize.y, ms.y)
	
	if style: ms += style.get_minimum_size()
	
	return ms

func get_allowed_size_flags_horizontal() -> Array[int]:
	return [SIZE_FILL, SIZE_SHRINK_BEGIN, SIZE_SHRINK_CENTER, SIZE_SHRINK_END]

func get_allowed_size_flags_vertical() -> Array[int]:
	return [SIZE_FILL, SIZE_SHRINK_BEGIN, SIZE_SHRINK_CENTER, SIZE_SHRINK_END]

func _notification(what: int):
	match what:
		NOTIFICATION_MOUSE_ENTER:
			_hovering = true
			update()
		NOTIFICATION_MOUSE_EXIT:
			_hovering = false
			update()
		NOTIFICATION_DRAW:
			var ci := get_canvas_item()
			var size = Rect2(Vector2(), get_size())
			style.draw(ci, size)
			if has_focus():
				style_focused.draw(ci, size)
		NOTIFICATION_SORT_CHILDREN:
			var size := get_size()
			var ofs := Vector2()
			
			var sty = self.style
			
			size -= sty.get_minimum_size()
			ofs += sty.get_offset()
			
			for child in self.get_children(true):
				if (child as Control == null || !child.is_visible_in_tree()) || child.is_set_as_top_level():
					continue
			
				self.fit_child_in_rect(child, Rect2(ofs, size))
			
			pass

	
