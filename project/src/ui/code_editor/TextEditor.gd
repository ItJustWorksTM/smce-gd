extends TextEdit

onready var mainControl: Node = get_owner()
onready var textEditor: TextEdit = self

# Called when the node enters the scene tree for the first time.
func _ready():
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
	var other = ['interrupts','noInterrupts','CAN','setCursor','display','bit','read','peek','onReceive','onRequest','flush', 'requestFrom','endTransmission','beginTransmission','setClock', 'status','write','size_t','Stream','Serial','begin','end','stop','print','printf','println','delay','attach','readMsgBuf','sendMsgBuf','analogWrite','analogRead', 'digitalWrite', 'digitalRead', 'writeMicroseconds','pinMode','delayMicroseconds']
	for t in other:
		textEditor.add_keyword_color(t,Color(0.976563, 0.599444, 0.324249))
		
	textEditor.caret_blink = true
	textEditor.show_line_numbers = true
	textEditor.add_child(BraceEnabler.new())

func _init_content():
	#Standard text
	if(mainControl.src_file == null):
		textEditor.text = "Please open a file to edit"
	else:
		mainControl._load_content(mainControl.src_file)
	
