#
#  ProfileManager.gd
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

class_name ProfileManager
extends Reference

var saved_profiles: Dictionary = {}

func load_profiles() -> Array:
	var profile_path = Global.usr_dir_plus("config/profiles")
	var profiles = []
	saved_profiles = {}
	
	for profile_file in Util.ls(profile_path):
		var path: String = profile_path.plus_file(profile_file)
		
		var file = File.new()
		if file.open(path, File.READ) != OK:
			printerr("failed to read: %s" % path)
			continue
		
		var json = file.get_as_text()
		
		var parse_res := JSON.parse(json)
		
		if ! parse_res.result is Dictionary:
			printerr("%s: not a dictionairy" % path)
		
		var profile = ProfileConfig.new()
		Util.inflate_ref(profile, parse_res.result)
		
		profiles.push_back(profile)
		saved_profiles[profile] = path
		print("loaded profile: %s" % profile.profile_name)
	
	return profiles


func save_profile(profile: ProfileConfig) -> bool:
	var profile_path = Global.usr_dir_plus("config/profiles")
	var dir: Directory = Directory.new()
	
	if ! dir.dir_exists(profile_path) && ! Util.mkdir(profile_path, true):
		return false
	
	if saved_profiles.has(profile):
		profile_path = saved_profiles[profile]
	else:
		# Basically this is stupid but it works
		var i = 0
		while dir.file_exists(profile_path.plus_file("%d.json" % i)):
			i += 1
		profile_path += "/%d.json" % i
	
	if dir.file_exists(profile_path) && dir.remove(profile_path) != OK:
		printerr("FAILED TO DELETE EXISTING PROFILE FILE")
		return false
	
	var file := File.new()
	
	if file.open(profile_path, File.WRITE) != OK:
		printerr("FAILED TO OPEN NEW PROFILE FILE")
		return false
	
	var dict = Util.dictify(profile)
	var content = JSON.print(dict, "	")
	
	file.store_string(content)
	file.close()
	
	saved_profiles[profile] = profile_path
	
	print("saved profile: ", profile.profile_name)
	return true


func save_profiles(profiles: Array) -> void:
	for profile in profiles:
		if ! save_profile(profile):
			print("Could not save profile: ", profile.profile_name)

