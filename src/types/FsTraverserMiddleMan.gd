#
#  FsTraverserMiddleMan.gd
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

# What functionality do we want?
# - READ
# - [ ] Filtering, with ability to choose
# - [?] Item choosing (Open File, Open Folder, Select current folder, Open Any)
# I believe this is a gui feature? maybe middle man
# - [x] Item selecting
# - [?] Item destinction (file, folder)
# - [x] Pop directory
# action, pop_dir
# - [x] Path existence feedback (when typing)
# - [ ] Toggle hidden items
# - [x] Refresh view
# action, refresh?
# - [x] Setting abs dir
# action, set_dir
# - WRITE
# - [x] Folder creation
# action, create_dir
# - [ ] File saving (type name in header, then press save)
# might be gui feature, simply return the path instead?

class_name FsTraverserMiddleMan
extends MiddleManBase
var _impl := FsTraverser.new()

func _init():
    _props = {
        "can_pop": obsvr(false),
        "folders": obsvr([]),
        "files": obsvr([]),
        "full_path": obsvr(""),
        "selected": obsvr(""),
        "selected_path": obsvr(""),
        "is_valid": obsvr(true),
        "new_dir_name": obsvr(""),
        "new_dir_valid": obsvr(false)
    }
    pipe(_impl, ["pop", "open", "refresh"], "_update_items")
    pipe(_impl, ["set_full_path"], "_update_path")
    pipe(_impl, ["select", "unselect"], "_update_selected")
    
    _actions["set_new_dir_name"] = action("_set_new_dir")
    _actions["create_dir"] = action("_create_dir")

    _update_items(true)

func _create_dir():
    if _impl.create_dir(_props.new_dir_name.value):
        _actions.refresh.invoke()
        _actions.select.invoke([_props.new_dir_name.value])
        _set_new_dir("")

func _set_new_dir(name):
    _props.new_dir_name.value = name
    _props.new_dir_valid.value = _impl.can_create_dir(name)

func _update_path(res):
    _props.is_valid.value = res
    _update_items(res)

func _update_items(res):
    if !res: return
    _props.folders.value = _impl.folders
    _props.files.value = _impl.files
    _props.full_path.value = _impl.get_path()
    _props.can_pop.value = _impl.can_pop()
    _update_selected()

func _update_selected(res = true):
    if !res: return 
    _props.selected_path.value = _impl.get_selected_path()
    _props.selected.value = _impl._current_item
    _props.full_path.value = _impl.get_path()
