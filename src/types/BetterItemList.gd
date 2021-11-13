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

    func _init(n).(n): pass

    func _on_init():
        # This relies on the fact we can bind to property changes
        bind() \
            .items.to(self, "_update_list") \
            .selected.to(self, "_on_selected_change") \

        invoke() \
            ._on_selected.on(node, "item_selected") \
            ._on_activated.on(node, "item_activated")

    func _update_list(items):
        node.clear()
        for item in items:
            # TODO: get fucked
            node.add_item(item, node.get_icon("folder"))
    
    func _on_selected(index):
        if self.selected.value != index:
            _on_selected_change(self.selected.value)
            self.set_selected.invoke([index])
    
    func _on_activated(__):
        self.activate.invoke()
    
    func _on_selected_change(index):
        if index >= 0:
            node.select(index)
            node.ensure_current_is_visible()
        else:
            node.unselect_all()

func init_model():
    model = ViewModel.new(self)
    return ViewModel.builder(model)

