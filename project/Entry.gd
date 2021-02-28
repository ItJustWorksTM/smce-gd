extends Node

export var main_scene: PackedScene = null

onready var _header: Label = $Header
onready var _log: RichTextLabel = $Log
onready var _button: Button = $Button
onready var _request: HTTPRequest = $HTTPRequest

var error: String = ""


func _ready():
	print("OS: ", OS.get_name())
	print("Data dir: ", OS.get_user_data_dir())
	
	_button.connect("pressed", self, "_on_clipboard_copy")
	
	var dir = Directory.new()
	if dir.open("res://gdnative/lib/RtResources"):
		return _error("RtResources not found!")
	
	if ! Util.copy_dir("res://gdnative/lib/RtResources", "user://RtResources"):
		return _error("Failed to copy in RtResources")

	print("Copied RtResources")

	var bar = BoardRunner.new()
	if bar == null:
		return _error("Shared library not loaded")
	bar.free()
	
	var cmake_exec = yield(_download_cmake(), "completed")
	if ! cmake_exec:
		return _error("Failed to retrieve cmake")
	
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


var osi = {
	"X11": ["cmake-3.19.6-Linux-x86_64.tar.gz", "/cmake-3.19.6-Linux-x86_64/bin/cmake"],
	"OSX": ["cmake-3.19.6-macos-universal.tar.gz", "/cmake-3.19.6-macos-universal/CMake.app/Contents/bin/cmake"], # people using < macos 10.13 will have more problems anyways
	"Windows": ["cmake-3.19.6-win32-x86.zip", "/cmake-3.19.6-win32-x86/bin/cmake.exe"]
}


func _download_cmake():
	yield(get_tree(), "idle_frame")
	
	var da = osi.get(OS.get_name())
	var file: String = da[0]
	var file_path: String = "user://%s" % file
	
	if ! File.new().file_exists(file_path):
		print("Starting CMake download")
		_request.download_file = file_path + ".download"
		var url: String = "https://github.com/Kitware/CMake/releases/download/v3.19.6/%s" % file
		if ! _request.request(url):
			var ret = yield(_request, "request_completed")
			Directory.new().copy(_request.download_file, file_path)
			Directory.new().remove(_request.download_file)
			print("Completed CMake download")
			print(ret)
		else:
			return null
	else:
		print("CMake already downloaded")
	
	if ! Util.unzip(Util.user2abs(file_path), OS.get_user_data_dir()):
		return null
	
	var cmake_exec = OS.get_user_data_dir() + da[1]
	
	var cmake_ver = []
	var cmake_res = OS.execute(cmake_exec, ["--version"], true, cmake_ver)
	if cmake_res != 0:
		return false
	
	print("--\n%s--" % cmake_ver.front())
	
	return cmake_exec
