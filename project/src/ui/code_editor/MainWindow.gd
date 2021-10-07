extends Control

onready var close_btn: Button = $Close
onready var dropdown_btn: MenuButton = $DropDown
onready var fileDialog: FileDialog = $FileDialog
# Called when the node enters the scene tree for the first time.
func _ready():
	close_btn.connect("pressed", self, "_on_close")
	_init_dropdown()

# Initializes the dropdown menu button
func _init_dropdown():
	dropdown_btn.get_popup().connect("id_pressed",self, "_on_item_pressed")
	dropdown_btn.get_popup().add_item("Open File")
	dropdown_btn.get_popup().add_item("Save File")
	dropdown_btn.get_popup().add_item("Close")
	

func _on_close() -> void:
	queue_free()

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
	print(path) # Path to file that should be opened in the editor
				# Add functionallity here to open the file in the editor

# Function save a file
func _save_file():
	print("Save File Pressed") # Add functionallity here to call the editor save function
	


