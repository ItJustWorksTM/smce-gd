class_name UserConfigState extends Node

var default_config := Cx.value({})

var user_config_name = Cx.value("smce.json")

func get_config_for(path, key = "") -> Dictionary:
    return self.default_config.value()[key]
    path = str(path)
    var config_path = Fs.trim_trailing(path).plus_file(self.user_config_name.value())
    
    var conf = Fs.read_file_as_string(config_path)
    
    var json = JSON.new()
    
    var err = json.parse(conf)
    
    if err != OK || !(json.get_data() is Dictionary):
        return self.default_config.value()[key]
    
    return json.get_data()[key]

func set_default_config(conf: Dictionary):
    self.default_config.change(conf)

func override_config(path: String):
    pass

static func read_config(path, default) -> Tracked:
    return Cx.combine_map(
        [path as Tracked, default as Tracked],
        func(path: String, default: Dictionary):
            var config = default
            
            # read json and shit
            
            return config
    ) as Tracked

func g(path: Tracked) -> Tracked:
    return UserConfigState.read_config(path, default_config)

func _ctx_init(c: Ctx):
    c.register_as_state()
