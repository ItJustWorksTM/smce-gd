#
#  Entry.gd
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

extends Node

export var main_scene: PackedScene = null

onready var _header: Label = $Header
onready var _log: RichTextLabel = $Log
onready var _button: Button = $Button

var error: String = ""

const USER_DIR = "user://"


func _ready():
	var wiki_titles = yield(_fetch_wiki_titles(), "completed")
	_download_wiki_pages(wiki_titles)

	var custom_dir = OS.get_environment("SMCEGD_USER_DIR")
	if custom_dir != "":
		print("Custom user directory set")
		if !Global.set_user_dir(custom_dir):
			return _error("Failed to setup custom user directory")

	_button.connect("pressed", self, "_on_clipboard_copy")
	print("Reading version file..")
	var file = File.new()
	var version = "unknown"
	var exec_path = OS.get_executable_path()
	if file.open("res://share/version.txt", File.READ) == OK:
		version = file.get_as_text()
		file.close()

	Global.version = version

	OS.set_window_title("SMCE-gd: %s" % version)
	print("Version: %s" % version)
	print("Executable: %s" % exec_path)
	print("Mode: %s" % "Debug" if OS.is_debug_build() else "Release")
	print("User dir: %s" % Global.user_dir)
	print()

	var dir = Directory.new()

	if dir.open("res://share/RtResources") != OK:
		return _error("Internal RtResources not found!")

	if !Util.copy_dir("res://share/RtResources", Global.usr_dir_plus("RtResources")):
		return _error("Failed to copy in RtResources")

	if !Util.copy_dir("res://share/library_patches", Global.usr_dir_plus("library_patches")):
		return _error("Failed to copy in library_patches")

	Util.mkdir(Global.usr_dir_plus("mods"))
	Util.mkdir(Global.usr_dir_plus("config/profiles"), true)

	print("Copied RtResources")

	var bar = Toolchain.new()
	if !is_instance_valid(bar):
		return _error("Shared library not loaded")

	var res = bar.init(Global.user_dir)
	if !res.ok():
		return _error("Unsuitable environment: %s" % res.error())
	print(bar.resource_dir())
	bar.free()

	Global.scan_named_classes("res://src")

	# somehow destroys res://
	ModManager.load_mods()

	_continue()


func _continue():
	if !main_scene:
		return _error("No Main Scene")
	get_tree().change_scene_to(main_scene)


func _error(message: String) -> void:
	var file: File = File.new()
	var result = file.open("user://logs/godot.log", File.READ)
	var logfile = file.get_as_text()
	file.close()

	_log.text = logfile
	_header.text += "\n" + message
	error = "Error Reason: " + message + "\n" + logfile


func _on_clipboard_copy() -> void:
	OS.clipboard = error

# Fetch smce-gd GitHub wiki html, return all the wiki page names to downloaded
# TODO: Temporary solution (GitHub can change the html tags, breaking this)
func _fetch_wiki_titles():
	var wiki_file_name = "wiki.html"
	
	# Download the html
	var http_node = HTTPRequest.new()
	http_node.set_use_threads(true)
	add_child(http_node)
	var output_name = USER_DIR + wiki_file_name
	http_node.set_download_file(output_name)
	var download_link = "https://github.com/ItJustWorksTM/smce-gd/wiki.html"
	var error = http_node.request(download_link)
	yield(http_node, "request_completed")
	if error != OK:
		push_error("An error occurred in the HTTP request.")
		
	# Get the wiki pages names
	var file = File.new()
	var wiki_pages = []
	file.open(USER_DIR + wiki_file_name, File.READ)
	while not file.eof_reached():
		var line = file.get_line()
		if '<a class="flex-1 py-1 text-bold"' in line:
			line = line.split(">")[1].split("<")[0]
			line = line.replacen(" ", "-")
			wiki_pages.append(line)
	return wiki_pages
	
# Fetch smce-gd GitHub wiki into user directory
func _download_wiki_pages(wiki_pages_to_download) -> void:
	var base_url = "https://raw.githubusercontent.com/wiki/ItJustWorksTM/smce-gd/"
	for page in wiki_pages_to_download:
		var http_node = HTTPRequest.new()
		http_node.set_use_threads(true)
		add_child(http_node)
		var output_name = USER_DIR + page + ".md"
		http_node.set_download_file(output_name)
		var download_link = base_url + page + ".md"
		var error = http_node.request(download_link)
		if error != OK:
			push_error("An error occurred in the HTTP request.")
