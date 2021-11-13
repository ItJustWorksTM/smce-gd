#
#  DirCreatePopUp.gd
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

class_name DirCreatePopUp
extends PanelContainer

var model: ViewModel

onready var line_edit := $VBoxContainer/HBoxContainer/LineEdit
onready var create_btn := $VBoxContainer/HBoxContainer/Button

class ViewModel:
    extends ViewModelExt.WithNode

    func create_btn_disabled(can_create): return !can_create
    
    func _init(n).(n): pass
    
    func _on_init():
        bind() \
            .create_btn_disabled.dep([self.can_create]) \
            .text_prop.to(self, "_update_line_edit") \
            .create_btn_disabled.to(node.create_btn, "disabled")

        invoke() \
            ._on_text_changed.on(node.line_edit, "text_changed") \
            .on_create.on(node.create_btn, "pressed")
        
    func _update_line_edit(name):
        node.line_edit.text = ""
        node.line_edit.append_at_cursor(name)
    
    func _on_text_changed(text): self.set_text.invoke([text]) 

func init_model():
    model = ViewModel.new(self)
    return ViewModel.builder(model)
