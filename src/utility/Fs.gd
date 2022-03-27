class_name Fs

static func list_files(path: String, omit_base: bool = false, include_files: bool = true, include_dirs: bool = true, filters: Array = ["*"]) -> Array:
	var ret := []
	var dir = Directory.new()
	if dir.open(path) != OK:
		return ret
	dir.list_dir_begin()
	var file_name: String = dir.get_next()
	while file_name != "":
		
		var matched = false
		for pattern in filters:
			if file_name.matchn(pattern):
				matched = true
				break
		if matched:
			if dir.file_exists(file_name): 
				if include_files:
					ret.push_back(path.plus_file(file_name) if !omit_base else file_name)
			elif include_dirs:
					ret.push_back(path.plus_file(file_name) if !omit_base else file_name)
		file_name = dir.get_next()
	return ret

static func trim_trailing(path: String) -> String:
	if path.get_file() == "":
		return path.get_base_dir()
	return path

static func dir_exists(path: String) -> bool: return Directory.new().dir_exists(path)

static func file_exists(path: String) -> bool: return Directory.new().file_exists(path)

static func read_file_as_string(path: String) -> String:
	var file: File = File.new()
	var result = file.open(path, File.READ)
	var content = ""
	if result == 0:
		content = file.get_as_text()
	file.close()
	return content
