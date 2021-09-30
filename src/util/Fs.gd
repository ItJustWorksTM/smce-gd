#
#  Fs.gd
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

class_name Fs

static func cpdir(source: String, destination: String) -> bool:
	return _cpdir(source, destination)
	
static func _cpdir(path: String, to: String, base = null) -> bool:
	if ! base:
		base = path

	var dir = Directory.new()
	var err = dir.open(path)
	if err != OK:
		print("Path: ", path, " Error ", err)
		return false

	dir.list_dir_begin(true)
	var file_name = dir.get_next()
	while file_name != "":
		var abspath = dir.get_current_dir() + "/" + file_name
		var relativ = abspath.substr(base.length())
		if dir.current_is_dir():
			if ! mkdir(to + relativ, true):
				return false
			if ! _cpdir(abspath, to, base):
				return false
		else:
			dir.copy(abspath, to + relativ)
		file_name = dir.get_next()
	return true

static func mkdir(path: String, recursive: bool = false) -> bool:
	var dir: Directory = Directory.new()
	if dir.dir_exists(path):
		return true
	if (dir.make_dir_recursive(path) if recursive else dir.make_dir(path)) != OK:
		return false
	
	return true

static func write_file(path: String, content: String) -> bool:
	var file := File.new()
	if file.open(path, File.WRITE) != 0:
		return false
	file.store_string(content)
	file.close()
	return true

static func dir_exists(path: String) -> bool: return Directory.new().dir_exists(path)

static func file_exists(path: String) -> bool: return Directory.new().file_exists(path)

static func get_current_working_dir() -> String: 
	var test := Directory.new()
	assert(test.open(".") == 0)
	return test.get_current_dir()

static func read_file_as_string(path: String) -> String:
	var file: File = File.new()
	var result = file.open(path, File.READ)
	var content = ""
	if result == 0:
		content = file.get_as_text()
	file.close()
	return content
