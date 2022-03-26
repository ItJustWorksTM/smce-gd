class_name OV767X
extends HardwareBase

var fb: int = 0
var distort: float = 0.75
var fov = 90
var far = 300

@onready
var _fb: FrameBuffer = _rec[0]

func requires() -> Array:
	return [
		{c = framebuffer(0), ex = true}
	]

signal request_frame
signal resolution_changed

var _resolution: Vector2 = Vector2(0,0)
var resolution: Vector2:
	get: return _resolution

var _frequency: int = 0
var frequency: int:
	get: return _frequency

var _vflip: bool = false
var vflip: bool:
	get: return _vflip

var _hflip: bool = false
var hflip: bool:
	get: return _hflip

var _timer: Timer = Timer.new()

func _ready():
	_timer.autostart = true
	add_child(_timer)
	
	_timer.timeout.connect(func(): request_frame.emit())
	
	_poll_data()

func submit_frame(texture: Texture) -> bool:
	if resolution.x == 0 || resolution.y == 0:
		return true
	
	if Vector2(texture.get_height(), texture.get_width()) == resolution:
		var img: Image = texture.get_data()
		
		if vflip: img.flip_y()
		if hflip: img.flip_x()
		
		# TODO: error?
		_fb.write_rgb888(img.get_data())
		return true
	return false

func _process(_delta: float) -> void:
	_poll_data()

func _poll_data() -> void:
	var n_resolution := Vector2(_fb.get_width(), _fb.get_height())
	
	if n_resolution != resolution:
		_resolution = n_resolution
		resolution_changed.emit()
	
	var n_freq := _fb.get_freq()
	if n_freq != frequency:
		_frequency = n_freq
		if frequency > 0:
			_timer.wait_time = 1.0/frequency
			_timer.paused = false
		else:
			_timer.paused = true
	
	_hflip = _fb.needs_horizontal_flip() as bool
	_vflip = _fb.needs_vorizontal_flip() as bool
