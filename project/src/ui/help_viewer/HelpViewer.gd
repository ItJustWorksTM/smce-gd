#
#  HelpViewer.gd
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

extends Control

signal exited

onready var close_btn = $LogPopout/Panel/Control/VBoxContainer/MarginContainer/CloseButton
onready var center_label = $LogPopout/Panel/Control/EmptyLabel
onready var item_list = $LogPopout/Panel/Control/VBoxContainer/HBoxContainer/ItemList
onready var rich_text_label = $LogPopout/Panel/Control/VBoxContainer/HBoxContainer/RichTextLabel

const USER_DIR = "user://"
var wiki_pages = []
var wiki_content = []


class WikiPage:
	var title: String
	var content: String


func _ready():
	close_btn.connect("pressed", self, "_close")
	wiki_pages = _get_wiki_from_storage(USER_DIR)

	if wiki_pages.size() > 0:
		center_label.set_text("")  # TODO: Should remove the entire node?
	for page in wiki_pages:
		item_list.add_item(page.title)

	# Add on-click event
	item_list.connect("item_selected", self, "_on_help_selected")
	item_list.connect("nothing_selected", self, "_on_help_selected", [-1])
	
	rich_text_label.connect("meta_clicked", self, "_richtextlabel_on_meta_clicked")


func _get_wiki_from_storage(path: String) -> Array:
	var pages = []
	var array = Util.ls(path)
	for item in array:
		if item != "" && item.ends_with(".md"):
			var page = WikiPage.new()
			page.title = item.trim_suffix(".md").replace("-", " ")
			page.content = _read_wiki_file(item)
			if page.title == "Home":
				pages.push_front(page)
			else:
				pages.append(page)
	return pages


# Read line by line from the wiki file, format the text using BBCode, return the formatted content
func _read_wiki_file(file_name: String):
	var file = File.new()

	file.open(USER_DIR + file_name, File.READ)
	var content =  _markdown_to_bbcode(file)
	file.close()

	return str(content)


func _markdown_to_bbcode(file: File):
	var content : String
	var code_snippet = false
	while not file.eof_reached():
		var line = file.get_line()
		# Detects start of code snippet
		if line.begins_with("```") && code_snippet == false:
			code_snippet = true
			line = "[code][color=aqua]" + line.replace("```", "") + "[/color][/code]"
		# Content part of code snippet
		elif !line.begins_with("```") && code_snippet == true:
			line = "[code][color=aqua]" + line + "[/color][/code]"
		# End of code snippet
		elif line.begins_with("```") && code_snippet == true:
			line = line.replace("```", "")
			line = "[code][color=aqua]" + line + "[/color][/code]"
			code_snippet = false

		# Heading
		elif line.begins_with("## "):
			line = line.replacen("## ", "")
			line = "[b]" + line + "[/b]"
		elif line.begins_with("### "):
			line = line.replacen("### ", "")
			line = "[b][i]" + line + "[/i][/b]"
			
		# Note
		if "**note:**" in line:
			line = line.replacen("_**note:**", "note:")
			line = line.trim_suffix("_")
			line = "[i]" + line + "[/i]"

		# Image
		var img_width = 464  # depends on the window width
		if line.begins_with("![](https://i.imgur.com/"):
			line = line.replacen("![](", "").replacen(")", "")
			var image_file_name = line.split("/")[-1]
			_download_image(line, USER_DIR + image_file_name)
			line = "[img=<" + str(img_width) + ">]" + USER_DIR + image_file_name + "[/img]"

		# Link
		var hyperlink_position_start = 0
		var hyperlink_position_end_space = null
		var hyperlink_position_end_bracket = null
		var hyperlink_position_end = null
		if "https://" in line:
			hyperlink_position_start = line.find("https://")
			hyperlink_position_end_space = line.findn(" ", hyperlink_position_start)
			hyperlink_position_end_bracket = line.findn(")", hyperlink_position_start)
			if hyperlink_position_end_space == -1 && hyperlink_position_end_bracket == -1:
				hyperlink_position_end = line.length()
			elif hyperlink_position_end_space == -1 || hyperlink_position_end_bracket == -1:
				hyperlink_position_end = max(hyperlink_position_end_space, hyperlink_position_end_bracket)
			else:
				hyperlink_position_end = min(hyperlink_position_end_space, hyperlink_position_end_bracket)
			line = line.insert(hyperlink_position_start, "[url]")
			line = line.insert(hyperlink_position_end + 5, "[/url]")  # for some reason doesn't end at the actual end, need + 5
		line += "\n"
		content = content + line
	return content



func _richtextlabel_on_meta_clicked(meta):
	OS.shell_open(str(meta))


func _gui_input(event: InputEvent):
	if event.is_action_pressed("mouse_left"):
		_close()


# Added enter_tree() to initialize the screen
func _enter_tree() -> void:
	_open()


func _close() -> void:
	emit_signal("exited")
	var tween = TempTween.new()

	add_child(tween)
	tween.interpolate_property(self, "rect_scale:y", 1, 0, 0.3, Tween.TRANS_CUBIC)
	tween.interpolate_property(self, "modulate:a", 1, 0, 0.15)
	tween.start()

	yield(tween, "tween_all_completed")
	queue_free()


func _open() -> void:
	var tween = TempTween.new()
	add_child(tween)
	tween.interpolate_property(self, "rect_scale:y", 0, 1, 0.15, Tween.TRANS_CUBIC)
	tween.interpolate_property(self, "modulate:a", 0, 1, 0.15)
	tween.start()


# Find the selected help and update the text window
func _select_help() -> void:
	for n in item_list.get_item_count():
		if item_list.is_selected(n) == true:
			rich_text_label.clear()
			rich_text_label.append_bbcode(wiki_pages[n].content)


func _download_image(url: String, file_name: String):
	var http_node = HTTPRequest.new()
	http_node.set_use_threads(true)
	add_child(http_node)
	http_node.set_download_file(file_name)
	var error = http_node.request(url)
	yield(http_node, "request_completed")
	http_node.queue_free()
	if error != OK:
		push_error("An error occurred in the HTTP request.")


# Catch the on-click event
func _on_help_selected(_index: int) -> void:
	_select_help()
