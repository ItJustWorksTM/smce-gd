#
#  BoardControl.gd
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

class_name BoardControl
extends HBoxContainer

const SCENE_FILE := "res://src/scenes/BoardControl/BoardControl.tscn"

var model: ViewModel

onready var start_btn: Button = $Start
onready var suspend_btn: Button = $Suspend

const State = Main.BoardState

class ViewModel:
    extends ViewModelExt.WithNode

    signal start_board
    signal stop_board
    signal suspend_board
    signal resume_board

    func start_btn_disabled(state): return state == State.UNAVAILABLE

    func suspend_btn_disabled(state): 
        match state:
            State.RUNNING, State.SUSPENDED: return false
            _: return true

    func suspend_btn_text(state): 
        match state:
            State.SUSPENDED: return "Resume"
            _: return "Suspend"

    func start_btn_text(state): 
        match state:
            State.READY, State.UNAVAILABLE: return "Start"
            State.RUNNING, State.SUSPENDED: return "Stop"

    var _state

    func _init(n, state).(n):
        _state = state

        bind() \
            .suspend_btn_disabled.dep([state]) \
            .suspend_btn_text.dep([state]) \
            .start_btn_text.dep([state]) \
            .start_btn_disabled.dep([state])

        bind() \
            .suspend_btn_disabled.to(node.suspend_btn, "disabled") \
            .suspend_btn_text.to(node.suspend_btn, "text") \
            .start_btn_disabled.to(node.start_btn, "disabled") \
            .start_btn_text.to(node.start_btn, "text") \
        
        # Idea: unwrap observables if passed in
        conn(node.start_btn, "pressed", "toggle_start")
        conn(node.suspend_btn, "pressed", "toggle_suspend")
    
    func toggle_start():
        match _state.value:
            State.READY: emit_signal("start_board")
            State.RUNNING, State.SUSPENDED: emit_signal("stop_board")
    
    func toggle_suspend():
        match _state.value:
            State.SUSPENDED: emit_signal("resume_board")
            State.RUNNING: emit_signal("suspend_board")


func init_model(state):
    model = ViewModel.new(self, state)

func _ready():  
    pass

static func instance(): return load(SCENE_FILE).instance()

# warning-ignore-all:unused_signal
