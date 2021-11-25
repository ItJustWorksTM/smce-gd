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

    func _init(n).(n): pass

    func _on_init():
        bind() \
            .suspend_btn_disabled.dep([self.state]) \
            .suspend_btn_text.dep([self.state]) \
            .start_btn_text.dep([self.state]) \
            .start_btn_disabled.dep([self.state])

        bind() \
            .suspend_btn_disabled.to(node.suspend_btn, "disabled") \
            .suspend_btn_text.to(node.suspend_btn, "text") \
            .start_btn_disabled.to(node.start_btn, "disabled") \
            .start_btn_text.to(node.start_btn, "text") \
        
        invoke() \
            .toggle_start.on(node.start_btn, "pressed") \
            .toggle_suspend.on(node.suspend_btn, "pressed")
    
    func toggle_start():
        match self.state.value:
            State.READY: self.start_board.invoke([])
            State.RUNNING, State.SUSPENDED: self.stop_board.invoke([])
    
    func toggle_suspend():
        match self.state.value:
            State.SUSPENDED: self.resume_board.invoke([])
            State.RUNNING: self.suspend_board.invoke([])


func init_model():
    model = ViewModel.new(self)
    return ViewModel.builder(model)

func _ready():  
    pass

static func instance(): return load(SCENE_FILE).instance()

# warning-ignore-all:unused_signal
