@tool
extends Camera3D

# || Camera bounds (world coordinates) ||
@export var min_x: float = -50.0
@export var max_x: float = 50.0
@export var min_y: float = -10.0
@export var max_y: float = 30.0

# || Zoom limits (orthographic size) ||
@export var min_zoom: float = 5.0
@export var max_zoom: float = 50.0

# || Debugging ||
@export var show_debug_border: bool = true
@export var border_color: Color = Color(1, 0, 0, 1)
@export var print_zoom: bool = false

# || Internal ||
var touch_points: Dictionary = {}
var last_pinch_distance: float = -1.0
var border_mesh: ImmediateMesh
var border_instance: MeshInstance3D

func _ready() -> void:
	projection = Camera3D.PROJECTION_ORTHOGONAL
	size = clamp(size, min_zoom, max_zoom)
	if show_debug_border:
		_update_debug_border()

func _process(_delta: float) -> void:
	if print_zoom:
		print("Zoom size: ", size)

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			touch_points[event.index] = event.position
		else:
			touch_points.erase(event.index)
		return

	if event is InputEventScreenDrag:
		touch_points[event.index] = event.position

		# === One-finger drag ===
		if touch_points.size() == 1:
			var rel = event.relative
			var screen_size = get_viewport().size
			var aspect = screen_size.x / screen_size.y
			var half_height = size * 0.5
			var half_width = half_height * aspect

			var move_x = -rel.x * ((half_width * 2.0) / screen_size.x)
			var move_y = rel.y * ((half_height * 2.0) / screen_size.y)

			position.x += move_x
			position.y += move_y
			_clamp_camera_position()
			last_pinch_distance = -1.0  

		# === Two-finger pinch zoom ===
		elif touch_points.size() == 2:
			var keys = touch_points.keys()
			var pos1 = touch_points[keys[0]]
			var pos2 = touch_points[keys[1]]
			var distance = pos1.distance_to(pos2)

			if last_pinch_distance > 0:
				var diff = distance - last_pinch_distance
				var zoom_change = -diff * 0.01  
				size = clamp(size + zoom_change, min_zoom, max_zoom)
				_clamp_camera_position()

			last_pinch_distance = distance

	else:
		last_pinch_distance = -1.0

func _get_half_extents() -> Vector2:
	var screen_size = get_viewport().size
	var aspect = screen_size.x / screen_size.y
	var half_height = size * 0.5
	var half_width = half_height * aspect
	return Vector2(half_width, half_height)

func _clamp_camera_position() -> void:
	var half_extents = _get_half_extents()
	position.x = clamp(position.x, min_x + half_extents.x, max_x - half_extents.x)
	position.y = clamp(position.y, min_y + half_extents.y, max_y - half_extents.y)

func _update_debug_border() -> void:
	if border_instance and is_instance_valid(border_instance):
		border_instance.queue_free()

	border_mesh = ImmediateMesh.new()
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_color = border_color
	mat.set_flag(BaseMaterial3D.FLAG_DISABLE_DEPTH_TEST, true)

	border_mesh.surface_begin(Mesh.PRIMITIVE_LINE_STRIP, mat)
	border_mesh.surface_add_vertex(Vector3(min_x, min_y, 0))
	border_mesh.surface_add_vertex(Vector3(max_x, min_y, 0))
	border_mesh.surface_add_vertex(Vector3(max_x, max_y, 0))
	border_mesh.surface_add_vertex(Vector3(min_x, max_y, 0))
	border_mesh.surface_add_vertex(Vector3(min_x, min_y, 0))  
	border_mesh.surface_end()

	border_instance = MeshInstance3D.new()
	border_instance.mesh = border_mesh
	border_instance.name = "CameraDebugBorder"
	border_instance.visible = show_debug_border

	var root = get_tree().current_scene
	if root:
		root.call_deferred("add_child", border_instance)
	else:
		call_deferred("add_child", border_instance)
