#
#  ControlUtil.gd
#  Copyright 2022 ItJustWorksTM
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
