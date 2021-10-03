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

class_name Entry
extends Node

var _version_file := "res://assets/version.txt"
func get_version() -> String:
	var version = Fs.read_file_as_string(_version_file)
	if version == "":
		version = "Unknown"
	return version

func _ready():
	
	var title := "SMCE-gd: %s" % get_version()
	var exec_path := "Executable: %s" % OS.get_executable_path()
	var build_mode := "Mode: %s" % "Debug" if OS.is_debug_build() else "Release"
	var working_dir := "Working Dir: %s" % Fs.get_current_working_dir()
	
	OS.set_window_title(title)
	
	print(title)
	print(exec_path)
	print(build_mode)
	print(working_dir)
	
	var env_info = EnvInfo.new(".smcegd_home")
	print(env_info)
	
	var res
	
	res = assert_native_lib()
	if res.is_err():
		return bail(res.get_value())
	
	res = assert_suitable_env(env_info)
	if res.is_err():
		return bail(res.error())
	
	
	# Index classes
	
	# Apply mods
	
	# if everything was succesfull
	var main := Main.new(env_info)
	main.name = "Main"
	main.universe.add_world("Test/Test", load("res://src/scenes/Test/Test.tscn"))
	
	queue_free()
	call_deferred("replace_by", main)
	# else display error ui
	
	# return bail("I hate it here")


func bail(res: String):
	var error_log := Observable.new(read_error_log())
	var entry_fail_gui = EntryFailGui.instance()
	add_child(entry_fail_gui)
	entry_fail_gui.init_model(res, error_log)
	
	# give the operating system some time to flush the file
	yield(get_tree().create_timer(0.5), "timeout")
	error_log.value = read_error_log()


func read_error_log() -> String:
	return Fs.read_file_as_string("user://logs/godot.log")

# Will trip the debugger when in editor, but gets silently ignored once exported
# hence the test to try make an actual object.
func assert_native_lib() -> Result:
	var tc = Toolchain.new()
	var res = is_instance_valid(tc)
	return Result.new().set_if_err(res, "Failed to load native library")


func assert_suitable_env(env_info: EnvInfo):
	var tc = Toolchain.new()
	return tc.init(env_info.smce_resources_dir)

