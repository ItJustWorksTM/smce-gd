extends Spatial
func extern_class_name():
	return "Camera"

onready var viewport: Viewport = Viewport.new()
onready var timer: Timer = Timer.new()
onready var effect = ColorRect.new()
onready var viewport_root = Spatial.new()
onready var camera = Camera.new()

export var pin = 0
export(float, 0, 1) var distort = 0.75
export(float) var fov = 90
export(float) var far = 300

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
	
	timer.autostart = true
	add_child(timer)
	
	viewport.size = Vector2(640, 480)
	viewport.handle_input_locally = false
	viewport.hdr = false
	viewport.render_target_v_flip = true
	viewport.render_target_update_mode = Viewport.UPDATE_ALWAYS
	viewport.shadow_atlas_quad_0 = Viewport.SHADOW_ATLAS_QUADRANT_SUBDIV_1
	viewport.shadow_atlas_quad_3 = Viewport.SHADOW_ATLAS_QUADRANT_SUBDIV_16
	
	camera.fov = fov
	camera.far = far
	camera.current = true
	camera.transform.origin = Vector3(0, 1.198, -0.912)
	viewport_root.add_child(camera)
	
	var backbuffer = BackBufferCopy.new()
	backbuffer.copy_mode = BackBufferCopy.COPY_MODE_VIEWPORT
	viewport_root.add_child(backbuffer)
	
	effect.material = ShaderMaterial.new()
	effect.material.shader = preload("res://src/shaders/LensDistort.shader")
	viewport_root.add_child(effect)
	
	viewport.add_child(viewport_root)
	
	add_child(viewport)


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
	effect.get_material().set_shader_param("factor", distort)
	
	if ! view || ! view.is_valid():
		return
	var buffer = view.framebuffers(pin)
	var new_res = Vector2(buffer.get_width(), buffer.get_height())
	var new_freq = buffer.get_freq()
	if new_res != resolution:
		viewport.size = new_res
		effect.get_material().set_shader_param("resolution", viewport.size)
		effect.rect_size = new_res
		resolution = new_res
		
	if new_freq != fps && new_freq != 0:
		timer.wait_time = 1.0/new_freq
		fps = new_freq
	
	vflip = buffer.needs_vertical_flip()
	hflip = buffer.needs_horizontal_flip()
	
	if ! DebugCanvas.disabled:
		DebugCanvas.add_draw(camera.global_transform.origin, camera.global_transform.origin + camera.global_transform.basis.xform(Vector3.FORWARD), Color.yellow)


func visualize() -> Control:
	var visualizer = NodeVisualizer.new()
	visualizer.display_node(self, "visualize_content")
	return visualizer


func visualize_content() -> String:
	return "   Resolution: %dx%d\n   FPS: %d\n   V Flip: %s\n   H Flip: %s" % [resolution.x, resolution.y, fps, vflip, hflip]
