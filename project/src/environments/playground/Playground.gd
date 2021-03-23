extends Spatial

onready var cam_ctl: CamCtl = $CamCtl
var debug_car: Spatial = null

func _init() -> void:
	print("World initted")


func _input(event: InputEvent):
	if event.is_action_pressed("debug_car_spawn"):
		if debug_car:
			debug_car.queue_free()
		debug_car = preload("res://src/objects/ray_car/RayCar.tscn").instance()
		add_child(debug_car)
		debug_car.global_transform.origin = Vector3(0,3,0)
	
	if event.is_action_pressed("debug_car_cam") and debug_car:
		if cam_ctl.locked == debug_car:
			cam_ctl.free_cam()
		else:
			cam_ctl.lock_cam(debug_car)


func _ready():
	print_stray_nodes()

	cam_ctl.locked_cam = $LockedCam
	cam_ctl.free_cam = $FreeCam
	cam_ctl.interp_cam = $InterpolatedCamera
	
	cam_ctl.free_cam()
	
	$GUI/Control.cam_ctl = $CamCtl
	
	DebugCanvas.disabled = true
	Engine.time_scale = 1
