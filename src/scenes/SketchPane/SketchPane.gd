#
#  SketchPane.gd
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


class_name SketchPane
extends PanelContainer

const SCENE_FILE := "res://src/scenes/SketchPane/SketchPane.tscn"

onready var sketch_status_control: SketchStatusControl = $VBoxContainer/SketchStatusControl

onready var board_control: BoardControl = $VBoxContainer/BoardControl/Margin2/BoardControl

onready var vehicle_pos_reset_btn: Button = $VBoxContainer/VehicleControl/Margin2/HBox/ResetPosButton
onready var vehicle_toggle_follow_btn: Button = $VBoxContainer/VehicleControl/Margin2/HBox/ToggleFollowButton

onready var attachment_container: VBoxContainer = $VBoxContainer/AttachmentDisplay/Scroll/VBox

onready var close_btn: Button = $VBoxContainer/BoardControl/Margin/CloseButton

class ViewModel:
    extends ViewModelExt.WithNode

    signal remove_self()

    signal reset_vehicle_position()
    signal follow_vehicle()

    func board_toggles_disabled(state): return state == Main.BoardState.UNAVAILABLE   

    func _init(n).(n): pass

    func _on_init():


        bind() \
            .board_toggles_disabled.dep([self.board_state]) \

        bind() \
            .board_toggles_disabled.to(node.vehicle_pos_reset_btn, "disabled") \
            .board_toggles_disabled.to(node.vehicle_toggle_follow_btn, "disabled") \


        node.sketch_status_control.init_model() \
            .props() \
                .sketch_path.to(Observable.new("hello world.ino")) \
                .sketch_compiled.to(Observable.new(false)) \
            .actions() \
                .compile_sketch.to(ActionSignal.new()) \
                .open_log.to(ActionSignal.new()) \
            .init()
        
        node.board_control.init_model() \
            .props() \
                .state.to(self.board_state) \
            .actions() \
                .start_board.to(ActionSignal.new()) \
                .stop_board.to(ActionSignal.new()) \
                .suspend_board.to(ActionSignal.new()) \
                .resume_board.to(ActionSignal.new()) \
            .init()
        
        invoke() \
            .remove_self.on(node.close_btn, "pressed")

var model: ViewModel

func init_model():
    model = ViewModel.new(self)
    return ViewModel.builder(model)

func _ready():

    if true:
        var state = Observable.new(Main.BoardState.READY)

        init_model() \
            .props() \
                .board_state.to(state) \
            .actions() \
                .remove_self.to(ActionSignal.new()) \
            .init()

        while true:
            yield(get_tree().create_timer(2.0),"timeout")
            state.value = Main.BoardState.SUSPENDED
            yield(get_tree().create_timer(2.0),"timeout")
            state.value = Main.BoardState.RUNNING
            yield(get_tree().create_timer(2.0),"timeout")
            state.value = Main.BoardState.UNAVAILABLE
            yield(get_tree().create_timer(2.0),"timeout")
            state.value = Main.BoardState.RUNNING

static func instance(): return load(SCENE_FILE).instance()

# warning-ignore-all:unused_signal
