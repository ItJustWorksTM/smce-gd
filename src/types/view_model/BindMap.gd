#
#  BindMap.gd
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

class_name BindMap

class BindMapExt:
	var _vm
	
	var _property
	func _init(vm, property):
		_vm = vm
		_property = property
	
	func to(object, method, binds = []):
		_vm._vm.bind_change(_property, object, method, binds)
		return _vm
	
	func dep(arr):
		_vm._vm.bind_dependent(_property, arr)
		return _vm

var _vm
func _init(vm):
	_vm = vm

func _get(property):
	if _vm._func_map.has(property) || _vm.has_method(property):
		return BindMapExt.new(self, property)
	return null

