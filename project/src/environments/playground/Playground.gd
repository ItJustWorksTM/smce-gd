extends Spatial

func init_cam_pos() -> Transform:
	return $CamPosition.global_transform
