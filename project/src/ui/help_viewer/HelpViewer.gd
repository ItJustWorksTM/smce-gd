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

signal help_selected
signal exited

onready var close_btn = $LogPopout/Panel/Control/VBoxContainer/MarginContainer/CloseButton
onready var center_label = $LogPopout/Panel/Control/EmptyLabel
onready var item_list = $LogPopout/Panel/Control/VBoxContainer/HBoxContainer/ItemList
onready var rich_text_label = $LogPopout/Panel/Control/VBoxContainer/HBoxContainer/RichTextLabel

const WIKI_PATH = "./media/wiki/"
var wiki_pages = []
var wiki_content = []


class WikiPage:
	var title: String
	var content: String


func init() -> bool:
	print("Loading help viewer...")
	
	
	return true

func _ready():
	close_btn.connect("pressed", self, "_close")
	wiki_pages = _get_wiki_from_storage("user://")
	for page in wiki_pages:
		print("Title: " + page.title)
		#print("Content: " + page.content)
		
	if wiki_pages.size() > 0:
		center_label.set_text("") # TODO: Should remove the entire node?
	for page in wiki_pages:
		item_list.add_item(page.title)
		
	# Add on-click event
	item_list.connect("item_selected", self, "_on_help_selected")
	item_list.connect("nothing_selected", self, "_on_help_selected", [-1])
	# print("HelpViewer loaded!")


func _get_wiki_from_storage(path) -> Array:
	var pages = []
	var dir = Directory.new()
	if dir.open(path) == OK:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if !dir.current_is_dir() && file_name.ends_with(".md"):
				print('Reading wiki page: ' + file_name)
				var page = WikiPage.new()
				page.title = file_name.trim_suffix(".md").replace("-", " ")
				page.content = _read_wiki_file(file_name)
				if page.title == "Home":
					pages.push_front(page)
				else:
					pages.append(page)
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path: " + path)
	return pages

# Read line by line from the wiki file, format the text using BBCode, return the formatted content
func _read_wiki_file(file_name):
	var file = File.new()
	var content : String
	var index = 0
	var img_width = 384
	file.open("user://" + file_name, File.READ)
	while not file.eof_reached():
#		var start = 0
#		var end = null
#		var end_2 = null
#		var end_true = null
#		var line_length = 0
		var line = file.get_line()
		# Format the text using BBCode
		# TODO: Switch statement? Match statement (godot)?
		if line.begins_with("## "):
			line = line.replacen("## ", "")
			line = "[b]" + line + "[/b]"
		if line.begins_with("### "):
			line = line.replacen("### ", "")
			line = "[i]" + line + "[/i]"
		if line.begins_with("![](https://i.imgur.com/"):
			line = line.replacen("![](", "").replacen(")", "")
			print("Image to download: " + line)
			var image_file_name = line.split("/")[-1]
			download_texture(line, "user://" + image_file_name)
			line = "[img=<" + str(img_width) + ">]" + "user://" + image_file_name + "[/img]"
			index = index + 1
#		if "https://" in line:
#			start = line.find("https://")
#			end = line.findn(" ", start)
#			end_2 = line.findn(")", start)
#			end_true = min(end, end_2)
#			if end == null && end_2 == null:
#				end_true = line.length()
#			line = line.insert(start - 1, "[u]")
#			line = line.insert(end_true + 1, "[/u]")
		line += "\n"
		content = content + line;
	#var content = file.get_as_text()
	file.close()
	return content


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
	
	yield(tween,"tween_all_completed")
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
			# print("Item list select: Index ", n)

# TODO: Resolve downloading an image, now gets an error "ERROR: request: Condition "!is_inside_tree()" is true. Returned: ERR_UNCONFIGURED"
func download_texture(url : String, file_name : String):
	var http_node = HTTPRequest.new()
	http_node.set_use_threads(true)
	add_child(http_node)
	http_node.set_download_file(file_name)
	var error = http_node.request(url)
	if error != OK:
		push_error("An error occurred in the HTTP request.")


# Catch the on-click event
func _on_help_selected(_index: int) -> void:
	_select_help()
