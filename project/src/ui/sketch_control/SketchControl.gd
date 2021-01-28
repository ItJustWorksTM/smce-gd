extends VBoxContainer

onready var pause: Button = $Pause
onready var recompile: Button = $Recompile
onready var terminate: Button = $Terminate

var runner: BoardRunner = null setget set_runner
func set_runner(new_runner: BoardRunner) -> void:
	runner = new_runner
	if runner:
		runner.connect("status_changed", self, "_on_board_status_changed");
	_set_pause_text()

var disabled: bool = true setget set_disabled
func set_disabled(val: bool) -> void:
	disabled = val
	pause.disabled = val
	# recompile.disabled = val
	terminate.disabled = val

func _ready() -> void:
	pause.connect("pressed", self, "_on_pause_pressed")
	terminate.connect("pressed", self, "_on_terminate_pressed")
	recompile.connect("pressed", self, "_on_recompile_pressed")
	
	# not implemented yet
	recompile.disabled = true

func _set_pause_text() -> void:
	if runner.status() == SMCE.Status.SUSPENDED:
		pause.text = "resume"
	elif runner.status() == SMCE.Status.RUNNING:
		pause.text = "suspend"
	else:
		pause.text = "invalid"

func _on_pause_pressed() -> void:
	if runner.status() == SMCE.Status.SUSPENDED:
		runner.resume()
	elif runner.status() == SMCE.Status.RUNNING:
		runner.suspend()

func _on_terminate_pressed() -> void:
	runner.terminate()

func _on_recompile_pressed() -> void:
	# do magic
	pass

func _on_board_status_changed(status: int) -> void:
	print("board status: ", SMCE.Status.keys()[status])
	set_disabled(status != SMCE.Status.SUSPENDED and status != SMCE.Status.RUNNING)
	_set_pause_text()

