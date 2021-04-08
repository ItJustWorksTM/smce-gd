class_name ProfileConfig

var profile_name: String = "No Name"
var environment: String = "playground/Playground"
var slots: Array = []

func type_info() -> Dictionary:
	return {
		"slots": SmceHud.Slot,
	}


func is_equal(other) -> bool:
	if other.slots.size() != slots.size():
		return false
	
	if other.profile_name != profile_name:
		return false
	
	if other.environment != environment:
		return false
	
	for i in range(slots.size()):
		if !slots[i].is_equal(other.slots[i]):
			return false
	
	return true
