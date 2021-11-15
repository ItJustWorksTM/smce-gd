extends Tabs

onready var mainControl: Node = get_owner()
onready var tabs: Tabs = self

class fileinfo:
	var _index: int
	var _name: String
	var _path: String
	var _content: String
		
#Function that Initializes the tabssystem
func _ready():
	tabs.add_tab("+")
	tabs.tab_close_display_policy =Tabs.CLOSE_BUTTON_SHOW_NEVER

#Create a new tab when openning a new file
func _create_new_tab_with_content(content,path):
	#Save the content of the current file in memory
	_save_tab_content()
	#Get the name of the file
	var name = path.substr(path.get_base_dir().length()+1,path.length())
	tabs.remove_tab(tabs.get_tab_count()-1);	#Remove the + tab
	tabs.add_tab(name)							#Add the actuall tab
	tabs.add_tab("+")							#Add the + tab
	var newFile = fileinfo.new()				#Create an instance of fielinfo
	newFile._index 		= tabs.get_tab_count()-2		
	newFile._name 		= name
	newFile._content 	= content
	newFile._path 		= path
	mainControl.fileInfos[newFile._index] = newFile			#Store the info in memory
	tabs.current_tab = newFile._index			#Switch to the correct tab
	_show_new_file(newFile)						#Display the file content
	
#Displays a new file of the type fileInfo
func _show_new_file(file):
	if(file == null):
		mainControl.textEditor.text = "Please open a file to edit"
		mainControl.currentFileInfo = null
		return
	mainControl.textEditor.text = file._content
	mainControl.currentFileInfo = file
	
#Save the content of the file in memory (An array of fileInfo class objects)
func _save_tab_content():
	if(mainControl.currentFileInfo != null):
		mainControl.currentFileInfo._content = mainControl.textEditor.text
		mainControl.fileInfos[mainControl.currentFileInfo._index] = mainControl.currentFileInfo
		

#Signal when a tab is visually switched
func _on_Tabs_tab_changed(tab):
	#Do not display the x on the + button
	if(tabs.get_tab_title(tabs.current_tab) == "+"):
		tabs.tab_close_display_policy = Tabs.CLOSE_BUTTON_SHOW_NEVER
	#Display X only on active button if the active button is an actual tab 
	else:
		tabs.tab_close_display_policy = Tabs.CLOSE_BUTTON_SHOW_ACTIVE_ONLY
		

#Signal from clicking on a tab
func _on_Tabs_tab_clicked(tab):
	#Open file menu if pressed +
	if(tabs.get_tab_title(tabs.current_tab) == "+"):
		mainControl.fileDialogOperation = "OPEN"
		mainControl.fileDialog.popup()
		
		return
	#Otherwise if clicked on another tab switch tabs and content:
	
	#Get the info about the selected tab
	_save_tab_content()
	#First save the current file in memory (NOT ACTUAL SAVE AS FILE)
	var fileInfo = mainControl.fileInfos[tabs.current_tab]
	#Display the content for the selected tab	
	_show_new_file(fileInfo)

#Signal from pressing X on a tab
func _on_Tabs_tab_close(tab):
	#If pressing X on another tab switch to that tab
	if(tab != tabs.current_tab):
		tabs.current_tab = tab
		_on_Tabs_tab_clicked(tab)
		return
		
	#The following changes the index for all tabs and shifts them by one	
	var removedIndex = tab
	mainControl.fileInfos[removedIndex] = null
	tabs.remove_tab(removedIndex)
	var newIndex = 0
	for i in range(0, tabs.get_tab_count()):
		if(removedIndex != i):
			if(removedIndex < i):
				var fi = mainControl.fileInfos[i]
				fi._index = newIndex
				mainControl.fileInfos[newIndex] = fi
			newIndex = newIndex +1
			
	#Update the view
	_show_new_file(mainControl.fileInfos[tabs.current_tab])
	
	#If only the + tab is left do not allow the user to remove it
	if(tabs.get_tab_count() == 1):
		tabs.tab_close_display_policy = Tabs.CLOSE_BUTTON_SHOW_NEVER
