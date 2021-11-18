#
#  ProfileConfig.gd
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

class_name ProfileConfig

var profile_name: String = "No Name"
var environment: String = "playground/Playground"
var compiler: int = 0
var slots: Array = []

func type_info() -> Dictionary:
	return {
		"slots": SmceHud.Slot,
	}


func is_equal(other) -> bool:
	if other.slots.size() != slots.size():
		return false
	
	if other.profile_name != profile_name:
		return false
	
	if other.environment != environment:
		return false
		
	if other.compiler != compiler:
		return false
	
	for i in range(slots.size()):
		if !slots[i].is_equal(other.slots[i]):
			return false
	
	return true
