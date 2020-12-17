extends Control

var buf: String = ""
onready var input: LineEdit = $Panel/LineEdit
onready var label: Label = $Panel/Label
onready var tween: Tween = $Tween

func _input(event: InputEvent):
	if event.is_action_pressed("ui_accept"):
		if EmulGlue.has_board() and !input.text.empty():
			if EmulGlue.write_uart_n(0, input.text):
				input.clear()
			else:
				print("write failed")

func _process(delta):
	if EmulGlue.has_board():
		input.editable = true
		
		label.text = EmulGlue.get_uart_buf_n(0)
	else:
		input.editable = false

	
	
	


var paused = false;

func _on_Button_pressed():
	if EmulGlue.compile("/home/ruthgerd/test.ino"):
		var result = yield(EmulGlue, "compile_finished")
		print(result)



func _on_Timer_timeout():
	if label.text.empty() and input.text.empty():
		tween.interpolate_property($Panel, "rect_position:y", $Panel.rect_position.y, -25, 0.2,Tween.TRANS_CUBIC)
		tween.start()
		


func _on_LineEdit_text_changed(new_text):
	if !tween.is_active():
		tween.interpolate_property($Panel, "rect_position:y", $Panel.rect_position.y, 0, 0.2,Tween.TRANS_CUBIC)
		tween.start()


func _on_Button2_pressed():
	EmulGlue.pause_board()


func _on_Button3_pressed():
	EmulGlue.resume_board()
