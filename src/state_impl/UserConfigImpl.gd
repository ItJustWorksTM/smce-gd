class_name UserConfigImpl


static func user_config_impl(): return func(c: Ctx):
    c.inherits(Node)
    
    var state = c.register_state(UserConfigState, UserConfigState.new())

    var get_config_for := func(path, key = "") -> Dictionary:
        return state.default_config.value()[key]
        path = str(path)
        var config_path = Fs.trim_trailing(path).plus_file(state.user_config_name.value())
        
        var conf = Fs.read_file_as_string(config_path)
        
        var json = JSON.new()
        
        var err = json.parse(conf)
        
        if err != OK || !(json.get_data() is Dictionary):
            return state.default_config.value()[key]
        
        return json.get_data()[key]

    var set_default_config := func(conf: Dictionary):
        state.default_config.change(conf)

    var override_config := func(path: String):
        pass
