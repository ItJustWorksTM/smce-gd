extends Control

onready var close_btn: Button = $Close
onready var dropdown_btn: MenuButton = $DropDown
onready var fileDialog: FileDialog = $FileDialog
onready var textEditor: TextEdit = $TextEditor
onready var _path: String = ""

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
	dropdown_btn.get_popup().add_item("Close")

#Initializes the texteditor settings
func _init_TextEditor():
	textEditor.caret_blink = true
	textEditor.show_line_numbers = true
	#Minimap view
	#textEditor.minimap_draw = true
	#textEditor.minimap_width = 150
	

# Function that hides the editor when its closed with a dedicated button
func _on_close() -> void:
	set_visible(false)
	
# Function that displays the hidden editor	
func enableEditor() -> void:
	set_visible(true)

# Function to handle dropdown menu button options
# Options to open and save file
func _on_item_pressed(id):
	var name = dropdown_btn.get_popup().get_item_text(id)
	if name == "Open File":
		fileDialog.popup() # Opens file dialog for file selection
	elif name == "Save File":
		_save_file()
	elif name == "Close":
		_on_close()

# Function to collect the path of a selected file and send it to the editor
func _on_FileDialog_file_selected(path):
	#Save global path for quick save
	_path = path
	#Load text from file
	var content = fileLoader.loadFile(path)
	#Paste text into texteditor
	textEditor.text = (content)


# Function save a file
func _save_file():
	#save text into texteditor
	fileLoader.saveFile(_path,textEditor.text)
	


