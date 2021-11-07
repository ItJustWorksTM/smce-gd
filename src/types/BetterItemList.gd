#
#  BetterItemList.gd
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

class_name BetterItemList
extends ItemList

var model: ViewModel

class ViewModel:
    extends ViewModelExt.WithNode

    func items(items): return items

    var _selected = null

    func selected(s): return s

    var _set_selected

    func _init(n, _items, selected, set_selected, activate).(n):
        _set_selected = set_selected
        _selected = selected
        conn(node, "item_selected", "_on_selected")
        conn(node, "item_activated", "_on_activated", [activate])
        bind().items.dep([_items]).items.to(self, "_update_list")
        bind().selected.dep([_selected]).selected.to(self, "_on_selected_change")

    func _update_list(items):
        node.clear()
        for item in items:
            node.add_item(item, node.get_icon("folder"))
    
    func _on_selected(index):
        if _selected.value != index:
            _on_selected_change(_selected.value)
            _set_selected.invoke([index])
    
    func _on_activated(__, activate):
        activate.invoke()
    
    func _on_selected_change(index):
        if index >= 0:
            node.select(index)
            node.ensure_current_is_visible()
        else:
            node.unselect_all()

func init_model(items, selected, set_selected, activate):
    model = ViewModel.new(self, items, selected, set_selected, activate)


