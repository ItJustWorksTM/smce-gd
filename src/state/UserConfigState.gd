class_name UserConfigState extends Object

var default_config := Cx.value({})

var user_config_name = Cx.value("smce.json")

var get_config_for := func(path, key = ""): pass
var set_default_config := func(conf: Dictionary): pass
var override_config := func(path: String): pass
