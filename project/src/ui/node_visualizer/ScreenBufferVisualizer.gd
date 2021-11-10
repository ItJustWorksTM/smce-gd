#
#  ScreenBufferVisualizer.gd
#  Copyright 2021 ItJustWorksTM
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#

class_name ScreenBufferVisualizer
extends VBoxContainer

var _node: Node = null
var _visual_func: String = ""

var text_display: Label = Label.new()
var image_display: TextureRect = TextureRect.new()
var viewport: Viewport = Viewport.new()
var viewport_container: ViewportContainer = ViewportContainer.new()

func display_node(node: Node, visual_func: String) -> bool:
	if ! node || ! node.has_method(visual_func):
		return false
	_node = node
	_visual_func = visual_func
	
	add_child(viewport_container)
	viewport_container.add_child(viewport)
	viewport.add_child(image_display)
	
	# Needed to make sure that the viewport does not swallow clicks meant for the collapsable element
	viewport.set_disable_input(true)
	
	add_child(text_display)
	
	return true

func _process(_delta: float) -> void:
	if ! _node:
		return
	
	# values[0] = texture
	# values[1] = aspect ratio of image
	# values[2] = text
	var values = _node.call(_visual_func)

	image_display.texture = values[0]

	# Set max width of viewport and use aspect ration to determine height
	var aspect_ratio = values[1]
	if aspect_ratio == 0:
		viewport.size = Vector2(0, 0)
	else:
		viewport.size = Vector2(290, 290 * (1.0/aspect_ratio))
	
	# Expanding the display to fit the viewport
	image_display.set_anchors_and_margins_preset(Control.PRESET_TOP_LEFT, Control.PRESET_MODE_MINSIZE, 0)
	image_display.rect_min_size = viewport.size
	image_display.expand = true
	#image_display.stretch_mode = TextureRect.STRETCH_SCALE
	
	text_display.text = values[2]
				
