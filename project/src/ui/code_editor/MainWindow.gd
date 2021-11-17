extends Control

	
onready var close_btn: Button = $Close
onready var compile_btn: Button = $Compile
onready var dropdown_btn: MenuButton = $DropDown
onready var fileDialog: FileDialog = $FileDialog
onready var textEditor: TextEdit = $HBoxContainer/VBoxContainer/TextEditor
onready var tabs: Tabs = $HBoxContainer/VBoxContainer/Tabs
onready var file_tree: Tree = $HBoxContainer/FileTree
onready var collapse_btn: Button = $HBoxContainer/CollapseBtn
onready var lineLimit: LineEdit = $LineLimitField

var src_file = null
var currentFileInfo = null
var fileInfos = {}				#Keeps track of all fileInfo objects
var tree_filled = false
var sketch_owner = null

#SAVES CURRENT STATE OF filedialog operation
#Can have the following values:
# OPEN  NEWFILE  SAVE NEWPROJ
onready var fileDialogOperation: String = ""

onready var fileLoader = load("res://src/ui/file_dialog/FileLoader.gd").new()
# Called when the node enters the scene tree for the first time.
func _ready():
	close_btn.connect("pressed", self, "_on_close")
	compile_btn.visible = false
	compile_btn.connect("pressed",self, "_on_compile")
	_init_dropdown()
	textEditor._init_content()

# Initializes the dropdown menu button
func _init_dropdown():
	dropdown_btn.get_popup().connect("id_pressed",self, "_on_item_pressed")
	dropdown_btn.get_popup().add_item("Open File")
	dropdown_btn.get_popup().add_item("Save File")
	dropdown_btn.get_popup().add_item("New File")
	dropdown_btn.get_popup().add_item("New Arduino-Project")
	dropdown_btn.get_popup().add_item("Close")

# Function that hides the editor when its closed with a dedicated button
func _on_close() -> void:
	set_visible(false)

# Function that calls compile function and closes("hides") the editor
func _on_compile() -> void:
	sketch_owner._on_compile() #Running compile functionality in ControlPane instance
	_on_close()
	
# Function that displays the hidden editor	
func enableEditor() -> void:
	set_visible(true)
	
# Limit line length
func _input(event):
	if event is InputEventKey and event.pressed:
		var line = textEditor.cursor_get_line()
		var s = textEditor.get_line(line)
		if (event.as_text() == "Tab" && lineLimit.text != "" && s.length()>=(int(lineLimit.text)-1) && int(lineLimit.text) >= 10):
			textEditor.get_tree().set_input_as_handled()
		if event.get_unicode() != 0: # allow editing
			if (lineLimit.text != "" && s.length()>=int(lineLimit.text) && int(lineLimit.text) >= 10):
				textEditor.get_tree().set_input_as_handled() # ignore key press after limit

# Function to handle dropdown menu button options
# Options to open and save file
func _on_item_pressed(id):
	var name = dropdown_btn.get_popup().get_item_text(id)
	if name == "Open File":
		_open_file()
	elif name == "Save File":
		_save_file()
	elif name == "New File":
		_new_file()
	elif name == "New Arduino-Project":
		_new_proj()
	elif name == "Close":
		_on_close()
		
func _open_file():
	fileDialogOperation = "OPEN"
	fileDialog.mode = fileDialog.MODE_OPEN_FILE	#Change mode back to open file	
	fileDialog.popup() # Opens file dialog for file selection
	
#Function to create a new file
func _new_file():
	fileDialogOperation = "NEWFILE"
	fileDialog.mode = fileDialog.MODE_SAVE_FILE	#Change mode to open dir
	fileDialog.add_filter("*.ino; ino file")
	fileDialog.popup()	#Get path for new file
	fileDialog.clear_filters()
	
#Function to create a new file
func _new_proj():
	fileDialogOperation = "NEWPROJ"
	fileDialog.mode = fileDialog.MODE_SAVE_FILE	#Change mode to open dir
	fileDialog.add_filter("*.ino; ino file")
	fileDialog.popup()	#Get path for new file
	fileDialog.clear_filters()
	
# Function to collect the path of a selected file and send it to the editor
func _on_FileDialog_file_selected(path):
	if(src_file == null):
		src_file = path
		
	if(fileDialogOperation == "OPEN"):
		fileDialogOperation = ""
		_load_content(path)
		
	elif(fileDialogOperation == "NEWFILE" ):
		tabs._create_new_tab_with_content("",path)
		_save_file()
		
	elif(fileDialogOperation == "NEWPROJ"):
		var template = fileLoader.loadFile("res://NewArduinoTemplate.txt")
		var finalPath = path+"/"+path.get_file()+".ino"
		Directory.new().make_dir_recursive (path)
		tabs._create_new_tab_with_content(template,finalPath)
		_save_file()

# load file and create new tab and fill tree if it is not filled
func _load_content(path):
	var content = fileLoader.loadFile(path)
	#Tab management
	tabs._create_new_tab_with_content(content,path)
	_fill_tree()

# Update the file tree with file structure
func _fill_tree():
	if(!tree_filled):
		file_tree._fill_tree(src_file.get_base_dir())
		tree_filled = true

# Function save a file
func _save_file():
	if currentFileInfo != null:
		fileLoader.saveFile(currentFileInfo._path,textEditor.text)
		currentFileInfo._savedContent = currentFileInfo._content
		tabs._update_saved_status()

func _on_Collapse_btn_pressed():
	if(file_tree.is_visible_in_tree()):
		file_tree.visible = false
		collapse_btn.text = ">"
	else:
		file_tree.visible = true
		collapse_btn.text = "<"
