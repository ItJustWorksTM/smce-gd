class_name Util

static func copy_dir(path: String, to: String, base = null) -> bool:
	if ! base:
		base = path

	var dir = Directory.new()
	if ! dir.open(path) == OK:
		print("Path: ", path, " Not found")
		return false

	dir.list_dir_begin(true)
	var file_name = dir.get_next()
	while file_name != "":
		var abspath = dir.get_current_dir() + "/" + file_name
		var relativ = abspath.substr(base.length())
		if dir.current_is_dir():
			dir.make_dir_recursive(to + relativ)
			if ! copy_dir(abspath, to, base):
				return false
		else:
			dir.copy(abspath, to + relativ)
		file_name = dir.get_next()

	return true

static func user2abs(path: String) -> String:
	if ! path.begins_with("user://"):
		return path
	
	return OS.get_user_data_dir() + "/" + path.substr(7)

# Warning: expects system paths
static func unzip(file: String, working_dir: String) -> bool:
	if ! File.new().file_exists(file) || ! Directory.new().dir_exists(working_dir):
		return false
	
	match OS.get_name():
		"X11", "OSX":
			return OS.execute("tar", ["-C", working_dir, "-zxvf", file], true) == 0
		"Windows":
			return OS.execute("powershell.exe", ["Expand-Archive", "-Path", file, "-DestinationPath", working_dir], true) == 0
	
	return false
