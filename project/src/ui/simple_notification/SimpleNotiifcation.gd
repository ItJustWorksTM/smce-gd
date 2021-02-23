extends Button

signal stop_notify

onready var header: RichTextLabel = $Label
onready var button: Button = $Button
onready var progress: ColorRect = $ColorRect

onready var _animation: AnimationPlayer = $AnimationPlayer

func _ready():
	button.connect("pressed", self, "_on_stop_pressed")
	_animation.play("progress")
	_animation.seek(rand_range(0,10), true)

func _on_stop_pressed():
	button.disabled = true
	emit_signal("stop_notify")
