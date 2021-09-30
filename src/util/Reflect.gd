#
#  Reflect.gd
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

# Utility class containing reflection functions to inspect Objects
class_name Reflect

static func is_trivially_constructable(type: GDScript) -> bool:
	for s in type.get_script_method_list():
		if s["name"] == "_init":
			return s["args"].size() == 0
	return true

# Returns the number of arguments a method has.
static func get_arg_count(object: Object, method: String) -> int:
	for method_desc in object.get_method_list():
		if method_desc["name"] == method:
			return method_desc["args"].size()
	return 0

# Returns if given object the given property
static func has_property(object: Object, property: String) -> bool:
	return property in object

# Method that will compare objects by value, meaning it will reflect properties
# until it finds fundamental types to compare.
static func value_compare(rhs, lhs) -> bool:
	if rhs is Array and lhs is Array:
		if rhs.size() != lhs.size(): return false
		var i = 0
		for __ in rhs:
			if ! value_compare(rhs[i], lhs[i]): return false
			i += 1
		return true
	elif rhs is Dictionary and lhs is Dictionary:
		for key in rhs:
			if ! value_compare(rhs.get(key), lhs.get(key)): return false
		return true
	elif rhs is Object and lhs is Object:
		return value_compare(inst2dict2(rhs), inst2dict2(lhs))
	elif typeof(rhs) == typeof(lhs):
		return rhs == lhs
	return false

static func inst2dict2(value: Object) -> Dictionary:
	var ret := {
		"@subpath": "",
		"@path": ""
	}
	var script: Script = value.get_script()
	if script != null:
		if script is GDScript:
			ret = inst2dict(value)
		else:
			for property in script.get_script_property_list():
				ret[property.name] = value.get(property.name)
			ret["@path"] = script.resource_path
	return ret

static func inst2dict2_recursive(value):
	if value is Array:
		var ret := []
		for item in value: ret.append(inst2dict2_recursive(item))
		return ret
	elif value is Dictionary:
		var ret := {}
		for key in value: ret[key] = inst2dict2_recursive(value[key])
		return ret
	elif value is Object:
		return inst2dict2_recursive(inst2dict2(value))
	return value

static func dict2inst2(dict: Dictionary):
	var path = dict.get("@path", null)
	
	var _erase_success = dict.erase("@path") && dict.erase("@subpath")
	
	var script = load(path)
	if path != null && script != null && script is Script:
		if script is GDScript:
			return dict2inst(dict)
		else:
			var inst = script.new()
			for key in dict:
				print("setting: ", key, "with", dict[key])
				inst.set(key, dict[key])
			return inst
	return null

static func dict2inst2_recursive(value):
	if value is Array:
		var ret := []
		for item in value: ret.append(dict2inst2_recursive(item))
		return ret
	elif value is Dictionary:
		var ret := {}
		for key in value: ret[key] = dict2inst2_recursive(value[key])
		if ret.has("@path"):
			return dict2inst2(ret)
		else:
			return ret
	return value
