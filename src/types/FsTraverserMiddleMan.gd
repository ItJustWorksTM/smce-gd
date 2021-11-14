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
        "new_dir_valid": obsvr(false),
        "filters": obsvr({}),
        "active_filter": obsvr("")
    }
    pipe(_impl, ["pop", "open", "refresh", "set_filters", "set_active_filter"], "_update_items")
    pipe(_impl, ["set_full_path"], "_update_path")
    pipe(_impl, ["select", "unselect"], "_update_selected")
    
    _actions["set_new_dir_name"] = action("_set_new_dir")
    _actions["create_dir"] = action("_create_dir")

    _impl.set_filters(_props.filters.value)
    _impl.set_active_filter(_props.active_filter.value)
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
    _props.filters.value = _impl.filters
    _props.active_filter.value = _impl.active_filter
    _update_selected()

func _update_selected(res = true):
    if !res: return 
    _props.selected_path.value = _impl.get_selected_path()
    _props.selected.value = _impl._current_item
    _props.full_path.value = _impl.get_path()

