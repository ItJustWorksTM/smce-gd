extends Spatial

onready var cam_ctl: CamCtl = $CamCtl


func _init() -> void:
	print("World initted")


func _ready():
	print_stray_nodes()

	cam_ctl.locked_cam = $LockedCam
	cam_ctl.free_cam = $FreeCam
	cam_ctl.interp_cam = $InterpolatedCamera
	
	cam_ctl.free_cam()
	
	$GUI/Control.cam_ctl = $CamCtl
	
	DebugCanvas.disabled = true
	Engine.time_scale = 1
