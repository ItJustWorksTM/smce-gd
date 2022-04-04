extends Spatial

func init_cam_pos() -> Transform:
	return $CamPosition.global_transform

func get_spawn_position(hint: String) -> Transform:
	match hint:
		"debug_vehicle": return $DebugVehicleSpawn.global_transform
		_: return $VehicleSpawn.global_transform
