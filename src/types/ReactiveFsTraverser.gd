#
#  ReactiveFsTraverser.gd
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

class_name ReactiveFsTraverser
extends ViewModelExt.ReactiveWrapper
var _impl := FsTraverser.new()

func _init():
    builder(self) \
        .props() \
            .can_pop.to(obsvr(false)) \
            .folders.to(obsvr([])) \
            .files.to(obsvr([])) \
            .full_path.to(obsvr("")) \
            .selected.to(obsvr("")) \
            .selected_path.to(obsvr("")) \
            .is_valid.to(obsvr(true)) \
            .new_dir_name.to(obsvr("")) \
            .new_dir_valid.to(obsvr(false)) \
            .new_file_name.to(obsvr("")) \
            .new_file_valid.to(obsvr(false)) \
            .filters.to(obsvr({})) \
            .active_filter.to(obsvr("")) \
        .actions() \
            .from_dict(pipe(_impl, ["pop", "open", "refresh", "set_filters", "set_active_filter"], "_update_items")) \
            .from_dict(pipe(_impl, ["set_full_path"], "_update_path")) \
            .from_dict(pipe(_impl, ["select", "unselect"], "_update_selected")) \
            .set_new_dir_name.to(self._set_new_dir) \
            .set_new_file_name.to(self._set_new_file) \
            .create_dir.to(self._create_dir) \
        .init()

func _on_init():
    _impl.set_filters(self.filters.value)
    _impl.set_active_filter(self.active_filter.value)
    _update_items(true)

func _create_dir():
    if _impl.create_dir(self.new_dir_name.value):
        _actions.refresh.invoke()
        _actions.select.invoke([self.new_dir_name.value])
        _set_new_dir("")

func _set_new_dir(name):
    self.new_dir_name.value = name
    self.new_dir_valid.value = _impl.can_create_dir(name)

func _set_new_file(name):
    self.new_file_name.value = name
    self.new_file_valid.value = _impl.can_create_file(name)

func _update_path(res):
    self.is_valid.value = res
    _update_items(res)

func _update_items(res):
    if !res: return
    self.folders.value = _impl.folders
    self.files.value = _impl.files
    self.full_path.value = _impl.get_path()
    self.can_pop.value = _impl.can_pop()
    self.filters.value = _impl.filters
    self.active_filter.value = _impl.active_filter
    _update_selected()

func _update_selected(res = true):
    if !res: return 
    self.selected_path.value = _impl.get_selected_path()
    self.selected.value = _impl._current_item
    self.full_path.value = _impl.get_path()

