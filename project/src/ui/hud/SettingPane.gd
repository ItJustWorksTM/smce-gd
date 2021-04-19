extends PanelContainer

signal toggled

onready var toggle_btn: Button = $VBoxContainer/MarginContainer2/Toggle

onready var profile_name_input: LineEdit = $VBoxContainer/MarginContainer2/ProfileName

onready var switch_btn: Button = $VBoxContainer/MarginContainer/VBoxContainer/HBoxContainer/Switch
onready var reload_btn: Button = $VBoxContainer/MarginContainer/VBoxContainer/HBoxContainer/Reload
onready var save_btn: Button = $VBoxContainer/MarginContainer/VBoxContainer/HBoxContainer/Save

onready var world_list: OptionButton = $VBoxContainer/MarginContainer/VBoxContainer/HBoxContainer2/Worlds
onready var sketches_label: Label = $VBoxContainer/MarginContainer/VBoxContainer/Sketches
onready var boards_label: Label = $VBoxContainer/MarginContainer/VBoxContainer/Boards

onready var version_label: Label = $VBoxContainer/MarginContainer/Version

var profile: ProfileConfig = ProfileConfig.new()
var master_manager = null setget set_master_manager

func set_master_manager(mngr) -> void:
	master_manager = mngr
	_reflect_profile()

var unique_sketches: int = 0
var boards: Array = []

func _ready():
	toggle_btn.connect("pressed", self, "emit_signal", ["toggled"])
	reload_btn.connect("pressed", self, "_reload_profile")
	switch_btn.connect("pressed", self, "_switch_profile")
	save_btn.connect("pressed", self, "_save_profile")
	profile_name_input.connect("text_changed", self, "_change_profile_name")
	world_list.connect("item_selected", self, "_on_world_selected")
	version_label.text = "SMCE-gd: %s" % Global.version
	
	_update_envs()


func _reflect_profile() -> void:
	var profile: ProfileConfig = master_manager.active_profile
	
	if ! is_instance_valid(profile):
		return
	
	var pname = master_manager.active_profile.profile_name
	
	if profile_name_input.text != pname:
		profile_name_input.text = pname
	
	boards_label.text = "Boards: %d" % profile.slots.size()
	
	var map: Dictionary = {}
	for slot in profile.slots:
		map[slot.path] = null
	
	sketches_label.text = "Sketches: %d" % map.size()
	
	world_list.select(Global.environments.keys().find(profile.environment))


func _update_envs():
	for env in Global.environments.keys():
		world_list.add_item(env)


func _switch_profile() -> void:
	master_manager.show_profile_select()


func _reload_profile() -> void:
	master_manager.reload_profile()


func _save_profile() -> void:
	var profile_manager: ProfileManager = master_manager.profile_manager
	if profile_manager.saved_profiles.has(master_manager.orig_profile):
		var path: String = profile_manager.saved_profiles[master_manager.orig_profile]
		profile_manager.saved_profiles[master_manager.active_profile] = path
		profile_manager.saved_profiles.erase(master_manager.orig_profile)

	profile_manager.save_profile(master_manager.active_profile)
	master_manager.orig_profile = master_manager.active_profile
	master_manager.active_profile = Util.duplicate_ref(master_manager.active_profile)


func _change_profile_name(text: String) -> void:
	master_manager.active_profile.profile_name = text


func _on_world_selected(index: int) -> void:
	master_manager.active_profile.environment = world_list.get_item_text(index)
	master_manager.load_profile(master_manager.active_profile)


func _process(_delta) -> void:
	_reflect_profile()
	save_btn.disabled = master_manager.active_profile.is_equal(master_manager.orig_profile)
