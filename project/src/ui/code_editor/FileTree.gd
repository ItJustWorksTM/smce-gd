extends Tree

onready var mainControl: Node = get_owner()
onready var file_tree: Tree = self

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _fill_tree(path):
	var name = path.substr(path.get_base_dir().length()+1,path.length())
	var root = file_tree.create_item()
	root.set_text(0, name)
	add_files_to_tree(path, root)
	
func add_files_to_tree(path, parent):
	var dir = Directory.new()
	dir.open(path)
	dir.list_dir_begin(true, false)
	var file_name = dir.get_next()
	while file_name != "":
		var child = file_tree.create_item(parent)
		child.set_text(0, file_name)
		if dir.current_is_dir():
			add_files_to_tree(dir.get_current_dir() + "/" + file_name, child)
		else:
			child.set_metadata(0, dir.get_current_dir() + "/" + file_name)
		file_name = dir.get_next()

func _on_FileTree_item_activated():
	var path = file_tree.get_selected().get_metadata(0)
	if path != null:
		mainControl._load_content(path)
