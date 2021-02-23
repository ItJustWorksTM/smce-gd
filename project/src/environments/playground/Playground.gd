extends Spatial


func _init() -> void:
	print("World initted")


func _ready():
	print_stray_nodes()

	DebugCanvas.disabled = true
	Engine.time_scale = 1

