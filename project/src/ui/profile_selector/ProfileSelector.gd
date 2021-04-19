extends Control

var profile_button_t = preload("res://src/ui/profile_selector/ProfileButton.tscn")

signal profile_selected

onready var attach = $VBoxContainer/CenterContainer/MarginContainer/HBoxContainer
onready var fresh_btn = attach.get_node("Button")

func _ready() -> void:
	fresh_btn.connect("pressed", self, "_on_profile_pressed", [ProfileConfig.new()])


func display_profiles(arr: Array) -> void:
	for child in attach.get_children():
		if child != fresh_btn:
			child.queue_free()
	for profile in arr:
		var btn = profile_button_t.instance()
		attach.add_child(btn)
		btn.display_profile(profile)
		btn.connect("pressed", self, "_on_profile_pressed", [profile])
		


func _on_profile_pressed(profile) -> void:
	emit_signal("profile_selected", profile)


