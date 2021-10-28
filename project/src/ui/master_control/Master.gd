#
#  Master.gd
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

extends Node

var hud_t = preload("res://src/ui/hud/SmceHud.tscn")

onready var world = $World
onready var profile_select = $ProfileSelect
onready var hud_attach = $HUD
onready var hud = null
onready var screen_cover = $ScreenCover

var profile_manager = ProfileManager.new()
onready var sketch_manager = $SketchManager

var orig_profile: ProfileConfig = null
var active_profile: ProfileConfig = null


func _ready() -> void:
	profile_select.connect("profile_selected", self, "_on_profile_selected")
	
	profile_manager.load_profiles()
	
	show_profile_select()


func _input(event: InputEvent):
	if event.is_action_pressed("ui_home"):
		print_stray_nodes()
	if is_instance_valid(active_profile):
		if event.is_action_pressed("reload"):
			load_profile(active_profile)
		if event.is_action_pressed("ui_cancel"):
			show_profile_select()


func fade_cover(bruh: bool):
	var tween: Tween = TempTween.new()
	add_child(tween)
	
	if bruh:
		screen_cover.visible = bruh
	
	if !bruh:
		tween.interpolate_property(screen_cover, "modulate:a", 1, 0, 0.3, Tween.TRANS_CUBIC)
	else:
		tween.interpolate_property(screen_cover, "modulate:a", 0, 1, 0.3, Tween.TRANS_CUBIC)
	tween.start()
	
	yield(tween,"tween_all_completed")
	
	screen_cover.visible = bruh


func show_profile_select() -> void:
	yield(unload_profile(),"completed")
	yield(get_tree(), "idle_frame")
	orig_profile = null
	active_profile = null
	var tween: Tween = TempTween.new()
	add_child(tween)
	profile_select.display_profiles(profile_manager.saved_profiles.keys())
	profile_select.visible = true
	profile_select.rect_pivot_offset = profile_select.rect_size / 2
	tween.interpolate_property(profile_select, "modulate:a", 0, 1, 0.4, Tween.TRANS_CUBIC)
	tween.interpolate_property(profile_select, "rect_scale", Vector2(10,10), Vector2(1,1), 0.4, Tween.TRANS_CUBIC)
	tween.start()


func _on_profile_selected(profile: ProfileConfig) -> void:
	if ! is_instance_valid(profile):
		printerr("Invalid profile selected")
		return
	
	var tween: Tween = TempTween.new()
	add_child(tween)
	profile_select.rect_pivot_offset = profile_select.rect_size / 2	
	tween.interpolate_property(profile_select, "modulate:a", 1, 0, 0.4, Tween.TRANS_CUBIC)
	tween.interpolate_property(profile_select, "rect_scale", Vector2(1,1), Vector2(10,10), 0.4, Tween.TRANS_CUBIC)
	tween.start()
	
	yield(get_tree().create_timer(0.35), "timeout")
	load_profile(profile)
	
	yield(tween, "tween_all_completed")
	profile_select.visible = false


func reload_profile() -> void:
	load_profile(orig_profile)


func unload_profile() -> void:
	yield(get_tree(), "idle_frame")
	if ! is_instance_valid(active_profile):
		return
	yield(fade_cover(true), "completed")

	if is_instance_valid(hud):
		hud.queue_free()
	world.clear_world()


func load_profile(profile: ProfileConfig) -> void:
	if ! is_instance_valid(profile):
		return
	
	if is_instance_valid(active_profile):
		yield(unload_profile(), "completed")
	
	var env = Global.get_environment(profile.environment)
	if env == null:
		printerr("Invalid world: %s" % profile.environment)
		return
	
	if ! yield(world.load_world(env), "completed"):
		printerr("Could not load world: %s" % profile.environment)
		return
	
	if active_profile != profile:
		orig_profile = profile
		active_profile = Util.duplicate_ref(profile)
	
	
	hud = hud_t.instance()
	hud.ctl_cam = world.ctl_cam
	hud.profile = active_profile
	hud.sketch_manager = sketch_manager
	hud.master_manager = self
	hud_attach.add_child(hud)
	
	hud.add_slots(profile.slots)
	
	fade_cover(false)

