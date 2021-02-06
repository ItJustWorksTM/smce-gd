extends Spatial


func _init() -> void:
	print("World initted")


func _ready():
	DebugCanvas.disabled = true
	Engine.time_scale = 1
	$GUI/GlobalControl.connect("do_compile", self, "_compile_sketch")


func _compile_sketch(path: String) -> void:
	$SpawnPoint.compile_sketch(path)
