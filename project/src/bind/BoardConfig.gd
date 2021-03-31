class_name BoardConfigGD

static func set_if(obj, dict) -> void:
	for key in dict.keys():
		if key in obj:
			obj.set(key, dict[key])

static func get_if(dict, key, type, default):
	return dict[key] if dict.has(key) && typeof(dict[key]) == type else default

static func from_dict(dict: Dictionary) -> BoardConfig:
	var ret = BoardConfig.new()
	
	for driver in get_if(dict, "gpio_drivers", TYPE_ARRAY, []):
		var new = GpioDriverConfig.new()
		set_if(new, driver)
		ret.gpio_drivers.push_back(new)
		
	for channel in get_if(dict, "uart_channels", TYPE_ARRAY, []):
		var new = UartChannelConfig.new()
		set_if(new, channel)
		ret.uart_channels.push_back(new)
	
	for frame_buf in get_if(dict, "frame_buffers", TYPE_ARRAY, []):
		var new = FrameBufferConfig.new()
		set_if(new, frame_buf)
		ret.frame_buffers.push_back(new)
	
	print("Parsed Boardconfig: %d gpio driver(s), %d uart channel(s), %d frame buffer(s)" %[ret.gpio_drivers.size(), ret.uart_channels.size(), ret.frame_buffers.size()])
	
	return ret
