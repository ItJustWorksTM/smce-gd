#
#  FileTraverser.gd
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

class_name FsTraverser

# Patterns using String::match syntax
var filters: Dictionary = {} # <String, [String]>
var active_filter: String = ""

# Files present in currently open directory
var files: Array = []

# Folders present in currently open directory
var folders: Array = []

# true = hides items starting with a `.`
var ignore_hidden: bool = false

var _current_dir: String = ""
var _current_item: String = ""

func _init(base: String = Fs.absolute(".")):
    _current_dir = base
    refresh()

func create_dir(_name: String) -> bool:
    return Fs.mkdir(_current_dir.plus_file(_name))

func get_path() -> String:
    return _current_dir

func get_selected_path() -> String:
    return Fs.absolute(get_path().plus_file(_current_item) if _current_item.length() > 0 else get_path())

func refresh() -> bool:
    folders = Fs.list_files(_current_dir, true, false, true)
    files = Fs.list_files(_current_dir, true, true, false, filters.get(active_filter, []))

    if !(_current_item in folders || _current_item in files):
        _current_item = ""
        print("sorry nothing")
    
    return true

func is_valid() -> bool:
    print("is valid?")
    return Fs.dir_exists(_current_dir)

func open() -> bool:
    var p = get_selected_path()
    if !Fs.dir_exists(p): return false
    print("Open: ", p)
    _current_dir = p
    _current_item = ""
    refresh()
    return true

static func _trim_trailing(path: String) -> String:
    if path.get_file() == "":
        return path.get_base_dir()
    return path

func can_pop():
    return _current_dir != _current_dir.get_base_dir()

func pop() -> bool:
    if !can_pop(): return false
    var before = _current_dir
    
    _current_dir = _trim_trailing(_current_dir).get_base_dir()
    print("Pop: ", before, " -> ", _current_dir)
    _current_item = ""
    refresh()
    return true

func select(name: String) -> bool:
    var p = _current_dir.plus_file(name)
    print("Select: ", p)
    if !Fs.exists(p): return false
    _current_item = name

    return true

func unselect():
    _current_item = ""

func set_full_path(path: String) -> bool:
    if path == "":
        return false
    # If the path point to a directory we just open it
    if Fs.dir_exists(path):
        _current_dir = path
        _current_item = ""
    # If the path points to a file we want to open the directory
    # and select the file
    elif Fs.file_exists(path):
        _current_dir = path.get_base_dir()
        _current_item = path.get_file()
    else:
        return false
    refresh()
    return true

func can_create_dir(name: String) -> bool:
    if name.length() == 0: return false
    print("its fine!")
    return true

func set_filters(dict: Dictionary) -> bool:
    filters = dict
    active_filter = ""
    refresh()
    return true

func set_active_filter(name: String) -> bool:
    if !filters.has(name): return false
    active_filter = name
    refresh()
    return true

# warning-ignore-all:return_value_discarded
