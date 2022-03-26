class_name FreeCamera
extends Camera3D

var velocity: Vector3 = Vector3()
var velocity2: Vector3 = Vector3()
var dragging: bool = false
var last_mouse_pos = Vector2(-1, -1)

var target_position: Vector3 = self.position
var target_rotation: Vector3 = self.rotation

func _input(event: InputEvent) -> void:
	var strength = func(action): return int(event.is_action_pressed(action)) - int(event.is_action_released(action))
	
	self.velocity += Vector3(0, 0, -strength.call("camera_forward"))
	self.velocity += Vector3(0, 0, strength.call("camera_backward"))
	self.velocity += Vector3(strength.call("camera_right"), 0, 0)
	self.velocity += Vector3(-strength.call("camera_left"), 0, 0)
	self.velocity += Vector3(0, strength.call("camera_up"), 0)
	self.velocity += Vector3(0, -strength.call("camera_down"), 0)
	
	if event is InputEventMouse:
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT:
				self.dragging = event.pressed
				self.last_mouse_pos = event.position if self.dragging else Vector2(-1, -1)
		elif self.dragging:
			var delta = self.last_mouse_pos - event.position
			velocity2 += Vector3(delta.y, delta.x, 0)
			self.last_mouse_pos = event.position

func translate_local(offset: Vector3) -> Vector3:
	var ext = Transform3D().translated(offset)
	return (self.transform * ext).origin - self.transform.origin

func _process(delta: float) -> void:
	self.target_position += self.translate_local(40 * self.velocity * Vector3(1,0,1) * delta)
	self.target_position.y += 40 * self.velocity.y * delta
	self.target_rotation += velocity2 * delta
	self.target_rotation.x = clamp(self.target_rotation.x, - PI / 2, PI / 2)
	self.velocity2 = Vector3()
	
	self.position = self.position.lerp(self.target_position, delta * 10)
	self.rotation = self.rotation.lerp(self.target_rotation, delta * 30)
	self.rotation.z = 0
