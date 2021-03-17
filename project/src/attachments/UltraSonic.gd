extends Spatial

export(int) var pin = 18

export(float, 0, 90, 0.1) var max_angle = 10.0 setget _update_angle
export(int, 0, 50, 1) var max_distance = 10 setget _update_distance
export(int, 0, 50, 1) var min_distance = 2
export(Array, int) var layers = [] setget _update_layers

var raycasts = []
var _flat_raycasts = []

var color = []

var _view = null

var distance: float = 0

func set_view(view) -> void:
	if ! view:
		return
	
	_view = view
	
	view.connect("validated", self, "set_physics_process", [false])
	view.connect("invalidated", self, "set_physics_process", [true])
		
	set_physics_process(view.is_valid())


func _ready():
	randomize()
	_update_layers()
	set_physics_process(false)

func _update_distance(distance: float = max_distance) -> void:
	max_distance = distance
	for ray in _flat_raycasts:
		ray.cast_to = Vector3.FORWARD * max_distance


func _update_angle(angle: float = max_angle) -> void:
	max_angle = angle
	for i in range(raycasts.size()):
		var new_angle = deg2rad((raycasts.size() - i - (1 if i > 0 else 0)) * (max_angle / raycasts.size()))
		for j in range(raycasts[i].size()):
			raycasts[i][j].transform.basis = Basis()
			
			raycasts[i][j].rotate(Vector3(0,1,0), new_angle)
			raycasts[i][j].rotate(Vector3(0,0,1), PI/(raycasts[i].size() * 0.5) * j)


func _update_layers(_layers: Array = layers) -> void:
	layers = _layers
	for ray in _flat_raycasts:
		ray.queue_free()
	_flat_raycasts = []
	raycasts.resize(layers.size())
	color.resize(layers.size())
	
	for i in range(0, layers.size()):
		var arr = []
		arr.resize(layers[i])
		
		color[i] = Color(rand_range(0,1), rand_range(0,1), rand_range(0,1))
		
		for j in range(0, layers[i]):
			arr[j] = RayCast.new()
			_flat_raycasts.push_back(arr[j])
			add_child(arr[j])
			
			arr[j].enabled =  true
		raycasts[i] = arr
	
	_update_angle()
	_update_distance()


func _physics_process(delta):
	var i = 0
	var distances = PoolRealArray()
	for rays in raycasts:
		for ray in rays:
			if ray.is_colliding():
				var dist: float = global_transform.origin.distance_squared_to(ray.get_collision_point())
				if dist > min_distance:
					distances.push_back(dist)
					if ! DebugCanvas.disabled:
						DebugCanvas.add_draw(global_transform.origin, ray.get_collision_point(), color[i])
		i += 1
	var dist = 0
	if ! distances.empty():
		dist = sqrt(distances[rand_range(0, distances.size())])
	
	distance = dist
	_view.write_analog_pin(pin, int(dist * 10))


func name() -> String:
	return "Ultrasonic Distance"


func visualize() -> Control:
	var visualizer = NodeVisualizer.new()
	visualizer.display_node(self, "visualize_content")
	return visualizer


func visualize_content() -> String:
	return "   Pin: %d\n   Distance: %.3fm" % [pin, distance]
