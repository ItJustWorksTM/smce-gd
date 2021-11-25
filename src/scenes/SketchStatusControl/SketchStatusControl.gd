#
#  SketchStatusControl.gd
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

class_name SketchStatusControl
extends PanelContainer

const SCENE_FILE := "res://src/scenes/SketchStatusControl/SketchStatusControl.tscn"

onready var sketch_name_label: Label = $VBox/SketchName
onready var sketch_status_label: Label = $VBox/SketchStatus

onready var compile_button: Button = $HBox/CompileButton
onready var log_button: Button = $HBox/LogButton

class ViewModel:
    extends ViewModelExt.WithNode

    func sketch_name(path): return path
    func sketch_status(is_compiled): return "Compiled" if is_compiled else "Not Compiled"

    func _init(n).(n): pass

    func _on_init():
        bind() \
            .sketch_name.dep([self.sketch_path]) \
            .sketch_status.dep([self.sketch_compiled]) \

        bind() \
            .sketch_status.to(node.sketch_status_label, "text") \
            .sketch_name.to(node.sketch_name_label, "text")

        invoke() \
            .compile_sketch.on(node.compile_button, "pressed") \
            .open_log.on(node.log_button, "pressed") \

    func open_log():
        # TBH this should make its own floating window ??
        # seems a bit much to signal this up for others to figure out
        pass

var model: ViewModel

func init_model():
    model = ViewModel.new(self)
    return ViewModel.builder(model)

static func instance(): return load(SCENE_FILE).instance()

# warning-ignore-all:unused_signal
