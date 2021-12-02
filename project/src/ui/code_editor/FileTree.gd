extends Tree

onready var mainControl: Node = get_owner()
onready var file_tree: Tree = self
onready var popupWindow = preload("res://src/ui/popup/popup_window.tscn")
onready var fileLoader = load("res://src/ui/file_dialog/FileLoader.gd").new()

var icon_folder
var icon_doc
var icon_refresh
var icon_delete
var src_file

# Called when the node enters the scene tree for the first time.
func _ready():
	file_tree.connect("button_pressed", self, "_on_FileTree_button_pressed")
	file_tree.connect("item_activated", self, "_on_FileTree_item_activated")
	
	icon_folder = resize_image_to_texture('res://media/images/outline_folder_white_48dp.png')
	icon_doc = resize_image_to_texture('res://media/images/outline_description_white_48dp.png')
	icon_refresh = resize_image_to_texture('res://media/images/outline_refresh_white_48dp.png')
	icon_delete = resize_image_to_texture('res://media/images/outline_delete_white_48dp.png')

func _update_tree(path):
	src_file = path
	var file_node = fileLoader.load_file_tree(path.get_base_dir())
	file_tree.clear()
	var root = file_tree.create_item()
	root.set_text(0, file_node._file_name)
	root.set_icon(0, icon_folder)
	root.add_button(0, icon_folder, 0)
	root.add_button(0, icon_refresh, 1)
	root.add_button(0, icon_delete, 2)
	
	_update_tree_add_children(file_node._children, root)
	
func _update_tree_add_children(children, parent):
	if children == null:
		return
	for c in children:
		var child = file_tree.create_item(parent)
		child.set_text(0, c._file_name)
		if c._is_folder:
			child.set_icon(0, icon_folder)
			_update_tree_add_children(c._children, child)
		else:
			child.set_icon(0, icon_doc)
			child.set_metadata(0, c._path)
		
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
			_update_tree(src_file)
		2:
			var path = file_tree.get_selected().get_metadata(0)
			if path != null:
				delete_file(path, file_tree.get_selected().get_text(0))

func delete_file(path, file_name):
	var popup = popupWindow.instance()
	get_tree().root.add_child(popup)
	popup.confirmation('Are you sure you want to delete: ' + file_name + '?')
	yield(popup,"click")
	var accept = popup.choice_ret()
	if accept:
		var dir = Directory.new()
		dir.remove(path)
		_update_tree(src_file)
