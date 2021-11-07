#
#  Profile.gd
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

# Profile struct used to describe a collection of sketches and accompanying test environment
class_name Profile

var name: String

# Array of SketchDescriptors
var sketches: Array

var environment: String

func _init(_name = "", _sketches = [], _environment = ""):
    name = _name
    sketches = _sketches
    environment = _environment

func clone(): return get_script().new(name, sketches, environment)
