extends Tree

onready var mainControl: Node = get_owner()
onready var file_tree: Tree = self
onready var popupWindow = preload("res://src/ui/popup/popup_window.tscn")



var icon_folder
var icon_doc
var icon_refresh
var icon_delete
var root_path

# Called when the node enters the scene tree for the first time.
func _ready():
	icon_folder = resize_image_to_texture('res://media/images/outline_folder_white_48dp.png')
	icon_doc = resize_image_to_texture('res://media/images/outline_description_white_48dp.png')
	icon_refresh = resize_image_to_texture('res://media/images/outline_refresh_white_48dp.png')
	icon_delete = resize_image_to_texture('res://media/images/outline_delete_white_48dp.png')

func _fill_tree(path):
	root_path = path
	var name = path.substr(path.get_base_dir().length()+1,path.length())
	var root = file_tree.create_item()
	root.set_text(0, name)
	root.set_icon(0, icon_folder)
	
	root.add_button(0, icon_folder, 0)
	root.add_button(0, icon_refresh, 1)
	root.add_button(0, icon_delete, 2)
	
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
			child.set_icon(0, icon_folder)
			add_files_to_tree(dir.get_current_dir() + "/" + file_name, child)
		else:
			child.set_metadata(0, dir.get_current_dir() + "/" + file_name)
			child.set_icon(0, icon_doc)
		file_name = dir.get_next()
		
func resize_image_to_texture(input):
	var texture = ImageTexture.new()
	var image = Image.new()
	image.load(input)
	image.resize(20, 20)
	texture.create_from_image(image)
	return texture
	
func _on_FileTree_item_activated():
	var path = file_tree.get_selected().get_metadata(0)
	if path != null:
		mainControl._load_content(path)
		
func _select_node(path):
	_select_node_util(file_tree.get_root(), path)

func _select_node_util(node, path):
	if node == null:
		return
	elif node.get_metadata(0) == path:
		node.select(0)
	else:
		var c = node.get_children()
		while(c):
			_select_node_util(c, path)
			c = c.get_next()
	
func _on_FileTree_button_pressed(item, column, id):
	match(id):
		0: 
			mainControl._open_file()
		1:
			file_tree.clear()
			_fill_tree(root_path)
		2:
			var path = file_tree.get_selected().get_metadata(0)
			if path != null:
				delete_file(path, file_tree.get_selected().get_text(0))

func delete_file(path, file_name):
	var popup = popupWindow.instance()
	get_tree().root.add_child(popup)
	popup.confirmation('Are you sure you want to delete: ' + file_name + '?')
	yield(popup,"click")
	var accept = popup.choiseRet()
	if accept:
		var dir = Directory.new()
		dir.remove(path)
		file_tree.clear()
		_fill_tree(root_path)

# Usage:
# Load this class: var popupWindow = preload("res://src/ui/popup/popup_window.tscn")
# Input following code where popup is needed:
# 	var popup = popupWindow.instance()
#	get_tree().root.add_child(popup)
#	Either popup.confirmation("your message") OR popup.info("your message")
#   Following only for confirmation popup:
#	yield(popup,"click")
#	var h = popup.choiseRet() - "no" = false, "yes" = true
#
