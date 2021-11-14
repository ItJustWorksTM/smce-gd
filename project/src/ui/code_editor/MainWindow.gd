extends Control

	
onready var close_btn: Button = $Close
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
#SAVES CURRENT STATE OF filedialog operation
#Can have the following values:
# OPEN  NEWFILE  SAVE NEWPROJ
onready var fileDialogOperation: String = ""

onready var fileLoader = load("res://src/ui/file_dialog/FileLoader.gd").new()
# Called when the node enters the scene tree for the first time.
func _ready():
	close_btn.connect("pressed", self, "_on_close")
	_init_dropdown()
	_init_TextEditor()

# Initializes the dropdown menu button
func _init_dropdown():
	dropdown_btn.get_popup().connect("id_pressed",self, "_on_item_pressed")
	dropdown_btn.get_popup().add_item("Open File")
	dropdown_btn.get_popup().add_item("Save File")
	dropdown_btn.get_popup().add_item("New File")
	dropdown_btn.get_popup().add_item("New Arduino-Project")
	dropdown_btn.get_popup().add_item("Close")

#Initializes the texteditor settings
func _init_TextEditor():
	#Standard text
	if(src_file == null):
		textEditor.text = "Please open a file to edit"
	else:
		_load_content(src_file)
	
	#Enable syntax highlightning
	textEditor.syntax_highlighting = true
	
	#Arduino syntax highlighting
	textEditor.add_color_region('//','',Color(0.638306, 0.65625, 0.65625)) # comments
	textEditor.add_color_region('/*','*/',Color(0.834412, 0.847656, 0.847656)) # info boxes
	textEditor.add_color_region('"','"',Color(0.085144, 0.605469, 0.56721)) # Strings

	#variables
	var varTypes = ['PROGMEM','sizeof','HIGH','LOW','OUTPUT','uint8_t','private','public','class','static','const','float','int','String','uint16_t','boolean','bool','void','byte','unsigned','long','char','uint32_t','word','struct']
	for v in varTypes:
		textEditor.add_keyword_color(v,Color(0.228943, 0.945313, 0.844573))
	
	#operators/keywords	
	var operators = ['ifndef','endif ','define','ifdef','include','setup','loop','if','for','while','switch','else','case','break','and','or','final','return']
	for o in operators:
		textEditor.add_keyword_color(o,Color(0.605167, 0.875, 0.071777))
	
	#stream, serial, other operations
	var other = ['interrupts','noInterrupts','CAN','setCursor','display','bit','read','peek','onReceive','onRequest','flush', 'requestFrom','endTransmission','beginTransmission','setClock', 'status','write','size_t','Stream','Serial','begin','end','stop','print','printf','println','delay','attach','readMsgBuf','sendMsgBuf']
	for t in other:
		textEditor.add_keyword_color(t,Color(0.976563, 0.599444, 0.324249))
		
	textEditor.caret_blink = true
	textEditor.show_line_numbers = true
	textEditor.add_child(BraceEnabler.new())

	#Minimap view
	#textEditor.minimap_draw = true
	#textEditor.minimap_width = 150
	

# Function that hides the editor when its closed with a dedicated button
func _on_close() -> void:
	set_visible(false)
	
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

func _on_Collapse_btn_pressed():
	if(file_tree.is_visible_in_tree()):
		file_tree.visible = false
		collapse_btn.text = ">"
	else:
		file_tree.visible = true
		collapse_btn.text = "<"
