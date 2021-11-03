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

onready var board_toggle_start_btn: Button = $VBoxContainer/BoardControl/Margin2/Hbox/BoardStartButton
onready var board_toggle_suspend_btn: Button = $VBoxContainer/BoardControl/Margin2/Hbox/BoardSuspendButton

onready var vehicle_pos_reset_btn: Button = $VBoxContainer/VehicleControl/Margin2/HBox/ResetPosButton
onready var vehicle_toggle_follow_btn: Button = $VBoxContainer/VehicleControl/Margin2/HBox/ToggleFollowButton

onready var attachment_container: VBoxContainer = $VBoxContainer/AttachmentDisplay/Scroll/VBox

onready var close_btn: Button = $VBoxContainer/BoardControl/Margin/CloseButton

class ViewModel:
    extends ViewModelExt.WithNode

    signal remove_self()

    signal reset_vehicle_position()
    signal follow_vehicle()

    signal start_board()
    signal stop_board()
    signal suspend_board()
    signal resume_board()

    func board_toggles_disabled(state): return state == Test.EMPTY

    func board_sus_disabled(state): 
        match state:
            Test.READY, Test.EMPTY: return true
            Test.RUNNING, Test.SUSPENDED: return false

    func board_suspend_btn_text(state): 
        match state:
            Test.READY, Test.EMPTY, Test.RUNNING: return "Suspend"
            Test.SUSPENDED: return "Resume"

    func board_start_btn_text(state): 
        match state:
            Test.READY, Test.EMPTY: return "Start"
            Test.RUNNING, Test.SUSPENDED: return "Stop"
    

    func _init(n, board_state).(n):
        node.sketch_status_control.init_model()

        bind() \
            .board_toggles_disabled.dep([board_state]) \
            .board_sus_disabled.dep([board_state]) \
            .board_start_btn_text.dep([board_state]) \
            .board_suspend_btn_text.dep([board_state]) \


        bind() \
            .board_toggles_disabled.to(node.board_toggle_start_btn, "disabled") \
            .board_start_btn_text.to(node.board_toggle_start_btn, "text") \
            .board_suspend_btn_text.to(node.board_toggle_suspend_btn, "text") \
            .board_sus_disabled.to(node.board_toggle_suspend_btn, "disabled") \
            .board_toggles_disabled.to(node.vehicle_pos_reset_btn, "disabled") \
            .board_toggles_disabled.to(node.vehicle_toggle_follow_btn, "disabled") \


        var alias = node.attachment_container

        for nice in [["label", "text"], ["label2", "text2"], ["label3", "text4"]]:
            var vis = VisibilityButton.new()
            vis.toggle_mode = true
            vis.text = nice[0]
            alias.add_child(vis)
            
            var text = Label.new()
            text.text = nice[1]
            alias.add_child(text)

            vis.node_path = text.get_path()


            pass

        fwd_sig(node.sketch_status_control.model, "compile_sketch")

        conn(node.close_btn, "pressed", "emit_signal", ["remove_self"])

var model: ViewModel

enum Test {
    READY,
    RUNNING,
    SUSPENDED,
    EMPTY
}

func init_model():
    var state = Observable.new(Test.EMPTY)
    model = ViewModel.new(self, state)

    # while true:
    #     yield(get_tree().create_timer(1.0), "timeout")

    #     if state.value == 0:
    #         state.value = 3
    #     else:
    #         state.value -= 1
        
    #     for s in Test.keys():
    #         if Test[s] == state.value:
    #             print(s)

static func instance(): return load(SCENE_FILE).instance()

# warning-ignore-all:unused_signal
