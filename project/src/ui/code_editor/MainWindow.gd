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
	


