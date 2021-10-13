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
