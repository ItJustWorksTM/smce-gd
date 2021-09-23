extends Control

onready var close_btn: Button = $Close

# Called when the node enters the scene tree for the first time.
func _ready():
	close_btn.connect("pressed", self, "_on_close")

func _on_close() -> void:
	queue_free()



