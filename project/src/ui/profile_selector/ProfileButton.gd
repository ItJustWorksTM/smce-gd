#
#  ProfileButton.gd
#  Copyright 2022 ItJustWorksTM
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

extends MarginContainer

signal pressed

onready var btn = $Button6

onready var name_label = $MarginContainer/VBoxContainer/Label
onready var extra_label = $MarginContainer/VBoxContainer/Label2

func _ready():
	btn.connect("pressed", self, "emit_signal", ["pressed"])

func display_profile(profile: ProfileConfig):
	name_label.text = "\n" + profile.profile_name
	var env_exists: bool = Global.environments.has(profile.environment)
	if !env_exists:
		modulate.a = 0.5
		btn.focus_mode = Control.FOCUS_NONE
		btn.disabled = true
	extra_label.bbcode_text = "[color=%s]World: %s[/color]\nSketches: %d" % ["white" if env_exists else "red",profile.environment, profile.slots.size()]
	
