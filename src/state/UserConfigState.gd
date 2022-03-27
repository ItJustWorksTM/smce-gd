class_name UserConfigState
extends Node

var default_config := Ui.value({})

var user_config_name = Ui.value("smce.json")

func get_config_for(path) -> Dictionary:
	path = str(path)
	var config_path = Fs.trim_trailing(path).plus_file(user_config_name.value)
	
	var conf = Fs.read_file_as_string(config_path)
	
	var json = JSON.new()
	
	var err = json.parse(conf)
	
	if err != OK || !(json.get_data() is Dictionary):
		return default_config.value
	
	return json.get_data()

func set_default_config(conf: Dictionary):
	default_config.value = conf

func override_config(path: String):
	pass
