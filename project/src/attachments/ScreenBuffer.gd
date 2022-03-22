class_name ScreenBuffer
extends Spatial

onready var mesh: MeshInstance = MeshInstance.new()
onready var screen: MeshInstance = MeshInstance.new()
var img: Image = Image.new()
var texture: ImageTexture = ImageTexture.new()

func extern_class_name():
	return "ScreenBuffer"

export var pin = 0
export var display_width = 0.34
export var display_height = 0.2
var resolution = Vector2(0, 0) # Base resolution (for MKRRGBMAtrix)
var image_buf = null
var fps = 1
var aspect_ratio = 1
var view = null
var timer: Timer = Timer.new()

func _ready():
	timer.connect("timeout", self, "_on_frame")
	timer.autostart = true
	add_child(timer)
	
	img.create(resolution.x, resolution.y, false, Image.FORMAT_RGB8)
	img.fill(Color.black)
	_create_texture()
	
	mesh.mesh = CubeMesh.new()
	_update_mesh_size()
	mesh.rotate_y(PI)
	
	screen.mesh = PlaneMesh.new()
	screen.scale_object_local(Vector3(0.9, 0.9, 0.9))
	screen.rotate_x(PI/2)
	screen.translate(Vector3(0, 1.5, 0))
	screen.material_override = SpatialMaterial.new()
	screen.material_override.albedo_texture = texture
	
	mesh.add_child(screen)
	add_child(mesh)

func _on_frame() -> void:
	if ! view || ! view.is_valid():
		return
		
	var new_image_buf = view.framebuffers(pin).read_rgb888(img)
	if new_image_buf != image_buf:
		img.create_from_data(resolution.x, resolution.y, 
			false, Image.FORMAT_RGB8, new_image_buf)
		_create_texture()
		image_buf = new_image_buf

func _physics_process(delta):
	var buffer = view.framebuffers(pin)
	var new_res = Vector2(buffer.get_width(), buffer.get_height())
	var new_fps = buffer.get_freq()
	
	if new_fps != fps and new_fps != 0:
		timer.wait_time = 1.0/new_fps
		fps = new_fps

	if new_res != resolution and new_res.x != 0 and new_res.y != 0:
		resolution = new_res
		aspect_ratio = float(resolution.x) / resolution.y
		_update_mesh_size()

	
func _create_texture():
	if texture.get_size() != resolution:
		texture.create_from_image(img, 0)
	else:
		texture.set_data(img)

func _update_mesh_size():
	if aspect_ratio >= 1:
		mesh.scale = Vector3(display_width, display_width / aspect_ratio, 0.025)
	else:
		mesh.scale = Vector3(display_height * aspect_ratio, display_height, 0.025)

func set_view(_view: Node) -> void:
	if ! _view:
		return
	view = _view

func visualize() -> Control:
	var visualizer = ScreenBufferVisualizer.new()
	visualizer.display_node(self, "visualize_content")
	return visualizer


func visualize_content() -> Array:
	var text =  "   Resolution: %dx%d" % [resolution.x, resolution.y]
	return [texture, aspect_ratio, text]
