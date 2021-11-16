extends Popup

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

onready var buttonOK = $buttonOK # for information popup
onready var buttonYes = $buttonYES # for confirmation popup
onready var buttonNo = $buttonNO # for confirmation popup
onready var msgLabel = $messageLabel # for both popup types
onready var panel = $Panel
signal click # for confirmation popup

var choice  # for confirmation popup, default


# Called when the node enters the scene tree for the first time.
func _ready():
	buttonOK.text = "OK"
	buttonOK.connect("pressed", self, "_buttonOK_pressed")
	buttonYes.text = "Yes"
	buttonYes.connect("pressed", self, "_buttonYes_pressed")
	buttonNo.text = "No"
	buttonNo.connect("pressed", self, "_buttonNo_pressed")

# Function to widen the window to support larger text
func widenWindow(var i):
	panel.margin_right = 793 + i * 30
	panel.margin_left = 511 - i * 30
	msgLabel.margin_right = 782 + i * 30
	msgLabel.margin_left = 522 - i * 30

# Call this to display informational popup with simple "OK" button
func info(message):
	var i = 1
	if (message.length()>112):
		i = (message.length()/28)-4
		widenWindow(i)
		msgLabel.text = message
		buttonYes.set_visible(false)
		buttonNo.set_visible(false)
		popup()
	else:
		msgLabel.text = message
		buttonYes.set_visible(false)
		buttonNo.set_visible(false)
		popup()

# Call this to display a popup with "yes" and "no" buttons
func confirmation(message):
	var i = 1
	if (message.length()>112):
		i = (message.length()/28)-4
		widenWindow(i)
		buttonYes.margin_right = 588 - i * 30
		buttonYes.margin_left = 491 - i * 30
		buttonNo.margin_left = 713 + i * 30
		buttonNo.margin_right = 810 + i * 30
		msgLabel.text = message
		buttonOK.set_visible(false)
		popup()
	else:
		msgLabel.text = message
		buttonOK.set_visible(false)
		popup()
		
	
func _buttonOK_pressed() -> void:
	queue_free()
	
func _buttonYes_pressed() -> void:
	choice = true
	emit_signal("click",choice)
	queue_free()
	
func _buttonNo_pressed() -> void:
	choice = false
	emit_signal("click",choice)
	queue_free()
	
# Returns user's choice (only for confirmation popup)
func choiseRet():
	return choice


