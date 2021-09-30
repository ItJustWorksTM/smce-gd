#
#  FileRefLink.gd
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

class_name FileRefLink

var path: String = ""
var ref: Reference = null

func save() -> bool:
	var content = JSON.print(Reflect.inst2dict2_recursive(ref), " ")
	return path != "" && ref != null && Fs.write_file(path, content)

static func from_file(path: String):
	if ! Fs.file_exists(path):
		return null
	
	var content := Fs.read_file_as_string(path)
	
	if content == "":
		return null
	
	var json = JSON.parse(content)
	
	if ! json.result is Dictionary:
		return null
	json = json.result
	
	var ref = Reflect.dict2inst2_recursive(json)
	
	var ret = load("res://src/types/FileRefLink.gd").new()
	ret.path = path
	ret.ref = ref
	
	return ret

static func from_ref(ref: Reference, save_dir: String):
	if ! Fs.dir_exists(save_dir):
		return null
	
	randomize()
	
	var file_name = _gen_filename()
	while Fs.file_exists(file_name): file_name = _gen_filename()
	
	var file_path := save_dir.plus_file(file_name)
	
	var ret = load("res://src/types/FileRefLink.gd").new()
	ret.path = file_path
	ret.ref = ref
	
	if ! ret.save():
		return null
	return ret

static func _gen_filename() -> String: return "%02x.json" % randi()
