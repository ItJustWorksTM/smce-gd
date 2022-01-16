#
#  Util.gd
#  Copyright 2022 ItJustWorksTM
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

class_name Util

static func copy_dir(path: String, to: String, base = null) -> bool:
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
			dir.make_dir_recursive(to + relativ)
			if ! copy_dir(abspath, to, base):
				return false
		else:
			dir.copy(abspath, to + relativ)
		file_name = dir.get_next()

	return true


static func read_json_file(path):
	var config = File.new()
	if config.open(path, File.READ) != OK:
		return null
	var json = config.get_as_text()
	config.close()

	var ret = JSON.parse(json)
	if typeof(ret.result) != TYPE_DICTIONARY:
		return null

	return ret.result


static func err(msg: String):
	var ret = GDResult.new()
	ret.set_error(msg)
	return ret


static func print_if_err(err):
	if ! err.ok():
		print(err.error())


class EmptyRef:
	pass

static func get_ref_props() -> Array:
	var default_props = EmptyRef.new().get_property_list()
	var names = []
	for props in default_props:
		names.push_back(props["name"])
	return names


static func get_custom_pops(ref) -> Array:
	var default_props = get_ref_props()
	
	var ret = []
	for props in ref.get_property_list():
		if ! default_props.has(props["name"]):
			ret.push_back(props["name"])
	
	return ret


static func inflate_ref(ref, dict: Dictionary):
	var type_info = {}
	if ref.has_method("type_info"):
		type_info = ref.type_info()
	
	for prop in get_custom_pops(ref):
		if ! dict.has(prop):
			continue
		
		var ti = type_info[prop] if type_info.has(prop) else null
		
		var dict_type = typeof(dict[prop])
		
		var prop_val = ref.get(prop)
		
		if prop_val is int && dict_type == TYPE_REAL:
			dict_type = TYPE_INT
			
		if ti == null && dict_type == typeof(prop_val):
			ref.set(prop, dict[prop])
		
		elif prop_val is Reference and dict_type == TYPE_DICTIONARY:
			inflate_ref(prop_val, dict[prop])
		
		elif prop_val is Array and dict_type == TYPE_ARRAY:
			var arr = []
			for thing in dict[prop]:
				if ti != null:
					if thing is Dictionary:
						var new: Reference = ti.new()
						arr.push_back(new)
						
						inflate_ref(new, thing)
					# we can only use dicts to inflate refs
				else:
					arr.push_back(thing)
			ref.set(prop, arr)


static func dictify(val, no_defaults = false):
	if val is Array:
		var arr = []
		for x in val:
			arr.push_back(dictify(x))
		return arr
	elif val is Reference:
		var dict = {}
		var base = val.get_script().new()
		for prop in get_custom_pops(val):
			if base.get(prop) != val.get(prop) || no_defaults:
				dict[prop] = dictify(val[prop])
		return dict
	elif val is Dictionary:
		var dict = {}
		for key in val:
			dict[key] = dictify(val[key])
		return dict
	return val


static func cond_yield(ref):
	var ret = ref
	if ref is GDScriptFunctionState:
		ret = yield(ref, "completed")
	else:
		yield(Engine.get_main_loop(), "idle_frame")
	return ret


static func mkdir(path, recursive: bool = false) -> bool:
	var dir: Directory = Directory.new()
	if dir.dir_exists(path):
		return true
	print("Creating dir: %s" % path)
	if (dir.make_dir_recursive(path) if recursive else dir.make_dir(path)) != OK:
		return false
	
	return true


static func ls(path: String) -> Array:
	var ret: Array = []
	
	var dir = Directory.new()
	if dir.open(path) != OK:
		return ret
	
	dir.list_dir_begin(true)
	
	var item = dir.get_next()
	
	while item != "":
		ret.push_back(item)
		item = dir.get_next()
	
	return ret


static func duplicate_ref(orig):
	var new = orig.get_script().new()
	
	inflate_ref(new, dictify(orig))
	
	return new


static func merge_dict_shallow(target, new) -> void:
	for key in new:
		target[key] = new[key]


static func set_props(object: Object, props: Dictionary) -> void:
	for prop in props:
		var val = props[prop]
		if val is String:
			val = str2var(val)
		object.set(prop, val)


static func merge_dict(a: Dictionary, b: Dictionary) -> Dictionary:
	var ret: Dictionary = a.duplicate()
	for key in b:
		var val = b[key]
		if val is Dictionary and a.get(key) is Dictionary:
			ret[key] = merge_dict(a.get(key), val)
		else:
			ret[key] = b[key]
	return ret
	
static func user2abs(path: String) -> String:
	if ! path.begins_with("user://"):
		return path

	return OS.get_user_data_dir() + "/" + path.substr(7)

# Warning: expects system paths
static func unzip(file: String, working_dir: String) -> bool:
	if ! File.new().file_exists(file) || ! Directory.new().dir_exists(working_dir):
		return false

	match OS.get_name():
		"X11", "OSX":
			return OS.execute("tar", ["-C", working_dir, "-zxvf", file], true) == 0
		"Windows":
			return OS.execute("powershell.exe", ["Expand-Archive", "-Path", file, "-DestinationPath", working_dir], true) == 0

	return false
