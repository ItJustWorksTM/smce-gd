#
#  TypeRegistry.gd
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

extends Node

var types: Dictionary setget ,get_types
var scripts: Dictionary setget ,get_scripts

func get_types() -> Dictionary:
    return types

func get_scripts() -> Dictionary:
    return scripts

func _init():
    var read: String = Fs.read_file_as_string("res://project.godot")

    var start = "_global_script_classes=["
    var begin = read.find(start) + start.length()

    var end = read.find("]", begin)

    var json_hopefully = read.substr(begin-1, end - begin + 2)

    var json = JSON.parse(json_hopefully)

    for obj in json.result:
        types[obj["class"]] = obj["path"]
        scripts[obj["path"]] = obj["class"]

