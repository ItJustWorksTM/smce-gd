#
#  SketchLoader.gd
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

class_name SketchLoader
extends Reference

var _cache := {}

var _sketch_config

func _init(sketch_config):
	_sketch_config = sketch_config

func skload(path: String): # -> Sketch
	path = Fs.parent_path(path)
	if ! Fs.dir_exists(path):
		return null
	
	if ! _cache.has(path) || !is_instance_valid(_cache[path]):
		
		var sk = Sketch.new()
		assert(sk != null)
		
		sk.init(path, _sketch_config)
		_cache[path] = sk
		
		sk.unreference()
		
		return sk
	
	return _cache[path]
