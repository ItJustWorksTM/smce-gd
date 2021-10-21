#
#  EntryFailGui.gd
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

class_name EntryFailGui
extends Control

const SCENE_FILE := "res://src/scenes/Entry/EntryFailGui/EntryFailGui.tscn"
static func instance():    return load(SCENE_FILE).instance()

onready var header_lbl := $Header
onready var log_lbl := $Log
onready var copy_btn := $CopyButton

class ViewModel:
    extends ViewModelExt.WithNode
    
    func log_content(val): return val
    func header_text(reason): return "FAILED TO INTIALIZE SMCE\n%s" % reason
    func full_error(reason, log_content): return "Error Reason: %s\n%s" % [reason, log_content]
    
    func _init(n, reason, log_content).(n):
        
        bind() \
            .log_content.to([log_content]) \
            .header_text.to([reason]) \
            .full_error.to([reason, log_content])
        
        bind() \
            .header_text.to(node.header_lbl, "text") \
            .log_content.to(node.log_lbl, "text")
        node.copy_btn.connect("pressed", self, "_on_copy_btn")
        
    func _on_copy_btn(): OS.clipboard = self.full_error

var model: ViewModel

func init_model(reason, log_content):
    model = ViewModel.new(self, Observable.from(reason), Observable.from(log_content))
