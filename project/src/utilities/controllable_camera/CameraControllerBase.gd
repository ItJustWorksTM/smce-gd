class_name CameraControllerBase

var cam: Spatial = null setget set_camera, get_camera

func _init(cam: Spatial):
	set_camera(cam)

func get_camera():
	return cam
	
func set_camera(camera: Camera):
	cam = camera

func cam_process(delta):
	pass

func cam_physics_process(delta) -> Transform:
	return cam.global_transform

func handle_event(event):
	pass
