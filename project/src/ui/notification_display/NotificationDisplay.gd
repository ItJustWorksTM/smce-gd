#
#  NotificationDisplay.gd
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

class_name NotificationDisplay
extends VBoxContainer

var attach: Control = null

func _ready() -> void:
	attach = Control.new()
	add_child(attach)

func add_notification(node: Control, timeout: float = -1) -> void:
	add_child_below_node(attach, node)
	node.modulate.a = 0
	
	var tween: Tween = Tween.new()
	add_child(tween)
	node.connect("stop_notify", self, "_remove_notification", [node])
	
	tween.interpolate_property(node, "modulate:a", node.modulate.a, 1, 0.3, Tween.TRANS_CUBIC)
	tween.start()
	yield(tween,"tween_all_completed")
	tween.queue_free()
	

	if timeout >= 0:
		yield(get_tree().create_timer(timeout), "timeout")
		_remove_notification(node)

func _remove_notification(node: Control) -> void:
	if ! node:
		return
	node.disconnect("stop_notify", self, "_remove_notification")
	
	var tween: Tween = TempTween.new()
	add_child(tween)
	if tween.is_inside_tree():
		tween.interpolate_property(node, "modulate:a", node.modulate.a, 0, 0.3, Tween.TRANS_CUBIC)
		tween.start()
		yield(tween,"tween_all_completed")
	
	node.queue_free()
