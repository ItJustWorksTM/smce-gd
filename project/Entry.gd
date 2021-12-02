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
#-------------------------------------------------------------------------------
onready var _request: HTTPRequest = $HTTPRequest
#-------------------------------------------------------------------------------

var error: String = ""


func _ready():
	#---------------------------------------------------------------------------
	print("OS: ", OS.get_name())
	print("Data dir: ", OS.get_user_data_dir())
	#---------------------------------------------------------------------------
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
	
	if ! Util.copy_dir("res://share/RtResources", Global.usr_dir_plus("RtResources")):
		return _error("Failed to copy in RtResources")
	
	if ! Util.copy_dir("res://share/library_patches", Global.usr_dir_plus("library_patches")):
		return _error("Failed to copy in library_patches")
	
	Util.mkdir(Global.usr_dir_plus("mods"))
	Util.mkdir(Global.usr_dir_plus("config/profiles"), true)
	
	print("Copied RtResources")

	var bar = Toolchain.new()
	if ! is_instance_valid(bar):
		return _error("Shared library not loaded")
	
	#var res = bar.init(Global.user_dir)
	#if ! res.ok():
	#	return _error("Unsuitable environment: %s" % res.error())
	print(bar.resource_dir())
	bar.free()
	
	Global.scan_named_classes("res://src")
	
	# somehow destroys res://
	ModManager.load_mods()
	#---------------------------------------------------------------------------
	var cmake_exec = yield(_download_cmake(), "completed")
	if ! cmake_exec:
		print("cmake not found")
		return _error("Failed to retrieve cmake")
	#---------------------------------------------------------------------------
	_continue()

func _continue():
	if ! main_scene:
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

#-------------------------------------------------------------------------------
var cmakeVersion = "3.19.6" 
var osi = {
	"X11": ["cmake-%s-Linux-x86_64.tar.gz"%cmakeVersion, "/cmake-%s-Linux-x86_64/bin/cmake"%cmakeVersion],
	"OSX": ["cmake-%s-macos-universal.tar.gz"%cmakeVersion, "/cmake-%s-macos-universal/CMake.app/Contents/bin/cmake"%cmakeVersion], # people using < macos 10.13 will have more problems anyways
	"Windows": ["cmake-%s-win32-x86.zip"%cmakeVersion, "/cmake-%s-win32-x86/bin/cmake.exe"%cmakeVersion]
}


func _download_cmake():
	yield(get_tree(), "idle_frame")

	var da = osi.get(OS.get_name())
	print(OS.get_name())
	print(osi.get(OS.get_name()))
	var file: String = da[0]
	var file_path: String = "user://%s" % file
	print("haha")
	var toolchain = Toolchain.new()
	print("Looking for CMake...")
	print(toolchain.check_cmake_availability())
	if true:
		
		#prompt user here--------------------------------------
		# NO CMAKE VERSION FOUND. DO YOU WANT TO INSTALL?
		#var window  = WindowDialog.new() 
		
		print("Starting CMake download")
		_request.download_file = file_path + ".download"
		print(file_path)
		print(file)
		print("1")
		var url: String = "https://github.com/Kitware/CMake/releases/download/v%s/%s" % [cmakeVersion, file]
		print(url)
		print("2")
		var res = _request.request(url)
		print(res)
		
		if ! res:
			print("3")
			var ret = yield(_request, "request_completed")
			print("4")
			Directory.new().copy(_request.download_file, file_path)
			print("5")
			Directory.new().remove(_request.download_file)
			print("Completed CMake download")
			print(ret)
		else:
			return null
		print("6")
		if ! Util.unzip(Util.user2abs(file_path), OS.get_user_data_dir()):
			return null
		var cmake_exec = OS.get_user_data_dir() + da[1]
		print("7")
		var cmake_ver = []
		print("8")
		var cmake_res = OS.execute(cmake_exec, ["--version"], true, cmake_ver)
		print("9")
		if cmake_res != 0:
			return false
		print("--\n%s--" % cmake_ver.front())
		return cmake_exec
	else:
		print("CMake already downloaded")
		return true
	
#-------------------------------------------------------------------------------
