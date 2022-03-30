class_name UserConfigState
extends Node

var default_config := Track.value({})

var user_config_name = Track.value("smce.json")

# get whatever config we say we give from this directory
func get_config_for(path, key = "") -> Dictionary:
    path = str(path)
    var config_path = Fs.trim_trailing(path).plus_file(user_config_name.value())
    
    var conf = Fs.read_file_as_string(config_path)
    
    var json = JSON.new()
    
    var err = json.parse(conf)
    
    if err != OK || !(json.get_data() is Dictionary):
        return default_config.value()[key]
    
    return json.get_data()[key]

func set_default_config(conf: Dictionary):
    default_config.change(conf)

func override_config(path: String):
    pass
