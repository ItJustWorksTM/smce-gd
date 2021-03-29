extends Spatial

onready var viewport: Viewport = $Viewport
onready var timer: Timer = $Timer

export var pin = 0

var view = null

var resolution = Vector2.ZERO
var fps = 0
var vflip: bool = false
var hflip: bool = false

func set_view(_view: Node) -> void:
	if ! _view:
		return
	
	view = _view


func _ready():
	timer.connect("timeout", self, "_on_frame")


func _on_frame() -> void:
	if ! view || ! view.is_valid():
		return
	
	var texture: Texture = viewport.get_texture()
	
	if texture.get_height() * texture.get_width() > 0:
		var img = texture.get_data()
		
		if vflip:
			img.flip_y()
		if hflip:
			img.flip_x()
		
		var ret = view.framebuffers(pin).write_rgb888(img)


func _physics_process(delta):
	
	viewport.get_camera().global_transform.origin = global_transform.origin
	viewport.get_camera().global_transform.basis = global_transform.basis
	
	if ! view || ! view.is_valid():
		return
		
	var buffer = view.framebuffers(pin)
	var new_res = Vector2(buffer.get_width(), buffer.get_height())
	var new_freq = buffer.get_freq()
	if new_res != resolution:
		viewport.size = new_res
		resolution = new_res
		
	if new_freq != fps && new_freq != 0:
		timer.wait_time = 1.0/new_freq
		fps = new_freq
	
	vflip = buffer.needs_vertical_flip()
	hflip = buffer.needs_horizontal_flip()


func visualize() -> Control:
	var visualizer = NodeVisualizer.new()
	visualizer.display_node(self, "visualize_content")
	return visualizer


func visualize_content() -> String:
	return "   Resolution: %dx%d\n   FPS: %d\n   V Flip: %s\n   H Flip: %s" % [resolution.x, resolution.y, fps, vflip, hflip]
