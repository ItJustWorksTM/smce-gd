# A class for loading files into the system
#
# Usage:
# var file_load = load("res://src/ui/file_dialog/FileLoader.gd")
# var content = file_load.loadFile ("path to file") #get file contents
# file_load.saveFile("path to file","content to record") #record into file
#
	


# returns file contents if file exists, null otherwise
static func loadFile(filepath: String):
	var f = File.new()
	if f.file_exists(filepath):
		f.open(filepath, File.READ)
		var content = ""
		while not f.eof_reached():
			var contentFragment = f.get_line()
			content+=contentFragment
			content+="\n"
		f.close()
		#print (content)
		return content
	return null
		
# records given string into the file
static func saveFile(filepath:String, content:String):
	var f = File.new()
	f.open(filepath,File.WRITE)
	var arr = content.split("\n")
	for str1 in arr:
		f.store_line(str1)
	f.close()
	
static func load_file_tree(path: String):
	var root = fileNode.new()
	root._path = path
	root._file_name = path.substr(path.get_base_dir().length()+1,path.length())
	_load_file_tree_util(root)	
	
	return root
	
static func _load_file_tree_util(node):
	var dir = Directory.new()
	dir.open(node._path)
	dir.list_dir_begin(true, false)
	
	var children = []
	
	var file_name = dir.get_next()
	while file_name != "":
		var child = fileNode.new()
		child._file_name = file_name
		child._path = dir.get_current_dir() + "/" + file_name
		if dir.current_is_dir():
			child._is_folder = true
			_load_file_tree_util(child)
		else:
			child._is_folder = false
		children.append(child)
		file_name = dir.get_next()
	node._children = children
	
class fileNode:
	var _path: String
	var _file_name: String
	var _children: Array
	var _is_folder: bool
	


