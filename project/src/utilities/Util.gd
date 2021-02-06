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
