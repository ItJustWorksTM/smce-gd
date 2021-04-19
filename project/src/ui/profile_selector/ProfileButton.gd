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
	
