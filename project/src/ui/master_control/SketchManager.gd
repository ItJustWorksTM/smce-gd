#
#  SketchManager.gd
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

class_name SketchManager
extends Node

signal sketch_added

var sketches: Dictionary = {}
var toolchains: Dictionary = {}


func get_sketch(path: String):
	if sketches.has(path):
		return sketches[path]
	return null


func get_toolchain(sketch: Sketch):
	if toolchains.has(sketch):
		return toolchains[sketch]
	return null


func make_sketch(path: String):
	var existing = get_sketch(path)
	if existing != null:
		return Util.err("Sketch already instanced")
	
	if ! File.new().file_exists(path):
		return Util.err("Sketch file does not exist")
	
	var base = path.get_base_dir().get_file()
	var file = path.get_basename().get_file()
	if base != file:
		return Util.err("Folder name should equal selected file name")
		
	var sketch = Sketch.new()
	sketch.init(path, Global.user_dir)
	
	var toolchain = Toolchain.new()
	add_child(toolchain)
	
	var res = toolchain.init(Global.user_dir)
	
	if ! res.ok():
		toolchain.set_free()
		return res
	
	sketches[path] = sketch
	toolchains[sketch] = toolchain
	
	emit_signal("sketch_added")
	
	return GDResult.new()

