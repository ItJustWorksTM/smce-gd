class_name UartPuller
extends HardwareBase

signal read

@onready
var _channel: UartChannel = _rec[0]

func requires() -> Array:
    return [
        {c = uartchannel(), ex=false}
    ]

var history_in: String = ""

func write(text: String) -> void:
    
    _channel.write(text)

func _process(_delta: float) -> void:
    var txt = _channel.read()
    if txt != "" && txt != null:
        read.emit(txt)
        history_in += txt
