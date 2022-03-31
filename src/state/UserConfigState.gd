class_name UserConfigState
extends Object

var default_config := Cx.value({})

var user_config_name = Cx.value("smce.json")

var get_config_for := func(path, key = "") -> Dictionary:
    return default_config.value()[key]
    path = str(path)
    var config_path = Fs.trim_trailing(path).plus_file(user_config_name.value())
    
    var conf = Fs.read_file_as_string(config_path)
    
    var json = JSON.new()
    
    var err = json.parse(conf)
    
    if err != OK || !(json.get_data() is Dictionary):
        return default_config.value()[key]
    
    return json.get_data()[key]

var set_default_config := func(conf: Dictionary):
    default_config.change(conf)

var override_config := func(path: String):
    pass
