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
onready var _request: HTTPRequest = $HTTPRequest

var error: String = ""


func _ready():
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
		
	var cmake_exec = yield(_download_cmake(), "completed")
	if ! cmake_exec:
		return _error("Failed to retrieve cmake")
	
	var res = bar.init(Global.user_dir)
	if ! res.ok():
		return _error("Unsuitable environment: %s" % res.error())
	print(bar.resource_dir())
	bar.free()
	
	Global.scan_named_classes("res://src")
	
	# somehow destroys res://
	ModManager.load_mods()

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
var cmakeVersion = "3.19.6" 
var osi = {
	"X11": ["cmake-%s-Linux-x86_64.tar.gz"%cmakeVersion, "cmake-%s-Linux-x86_64.tar"%cmakeVersion, "/bin/cmake"],
	"OSX": ["cmake-%s-macos-universal.tar.gz"%cmakeVersion, "cmake-%s-macos-universal.tar"%cmakeVersion, "/CMake.app/Contents/bin/cmake"], # people using < macos 10.13 will have more problems anyways
	"Windows": ["cmake-%s-win32-x86.zip"%cmakeVersion, "cmake-%s-win32-x86"%cmakeVersion, "/bin/cmake.exe"]
}


func _download_cmake():
	yield(get_tree(), "idle_frame")
	var toolchain = Toolchain.new()
	toolchain.init(Global.user_dir)
	print("Looking for CMake...")
	if !toolchain.check_cmake_availability().ok():
		toolchain.free()
		print("CMake not found")
		
		# If you want to promt the user with a window asking if they want to 
		# install cmake it could be added here. As it is now cmake will be installed
		# without asking the user for permission. 
		
		print("Downloading CMake...")
		
		var da = osi.get(OS.get_name())
		var file: String = da[0]
		var file_path = OS.get_user_data_dir() + ("\\%s" % file)
		
		_request.download_file = file_path + ".download"
		var url: String = "https://github.com/Kitware/CMake/releases/download/v%s/%s" % [cmakeVersion, file]
		var res = _request.request(url)
		var dir = Directory.new()
		if ! res:
			var ret = yield(_request, "request_completed")
			dir.copy(_request.download_file, file_path)
			dir.remove(_request.download_file)
			print("CMake Downloaded")
		else:
			print("Download Failed")
			return null
		print("Installing CMake...")
			
		var cmake_installation_path: String = Global.usr_dir_plus("RtResources")
		if ! Util.unzip(Util.user2abs(file_path), cmake_installation_path):
			print("unzip failed")
			return null
		dir.remove(file_path)
		dir.open(cmake_installation_path)
		dir.rename (da[1], "CMake")
		
		var cmake_exec = cmake_installation_path + "/CMake" + da[2]
		var cmake_ver = []
		var cmake_res = OS.execute(cmake_exec, ["--version"], true, cmake_ver)
		if cmake_res != 0:
			print("Installation Failed") # maybe not propper to say installation failed here. Maybe replace with: "something went wrong"?
			return false
			
		print("--\n%s--" % cmake_ver.front())
		print("CMake Installed")
		return cmake_exec
	else:
		print("CMake Found")
		toolchain.free()
		return true
