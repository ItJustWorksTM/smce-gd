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

    func _init(n, board_state).(n):
        node.sketch_status_control.init_model()

        node.board_control.init_model(board_state)


        bind() \
            .board_toggles_disabled.dep([board_state]) \

        bind() \
            .board_toggles_disabled.to(node.vehicle_pos_reset_btn, "disabled") \
            .board_toggles_disabled.to(node.vehicle_toggle_follow_btn, "disabled") \

        fwd_sig(node.sketch_status_control.model, "compile_sketch")

        fwd_sig(node.board_control.model, "suspend_board")
        fwd_sig(node.board_control.model, "resume_board")
        fwd_sig(node.board_control.model, "start_board")
        fwd_sig(node.board_control.model, "stop_board")

        conn(node.close_btn, "pressed", "emit_signal", ["remove_self"])

var model: ViewModel

func init_model():
    var state = Observable.new(Main.BoardState.READY)
    model = ViewModel.new(self, state)


    while true:
        var action = yield(Yield.many(model, ["suspend_board", "resume_board", "stop_board", "start_board"]), "completed")

        match action:
            "suspend_board":
                state.value = Main.BoardState.SUSPENDED
            "resume_board":
                state.value = Main.BoardState.RUNNING
            "stop_board":
                state.value = Main.BoardState.UNAVAILABLE
            "start_board":
                state.value = Main.BoardState.RUNNING




static func instance(): return load(SCENE_FILE).instance()

# warning-ignore-all:unused_signal
