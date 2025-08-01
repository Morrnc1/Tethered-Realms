extends Area3D

@export var build_position: Node3D
@export var visual_mesh: Node3D
var current_building: Node3D = null

func is_empty() -> bool:
	return current_building == null

func _ready():
	connect("input_event", Callable(self, "_on_input_event"))

func _on_input_event(camera, event, click_position, click_normal, shape_idx):
	if event is InputEventScreenTouch and event.pressed:
		on_slot_tapped()

func on_slot_tapped():
	if is_empty():
		var ui = get_tree().get_current_scene().get_node("UI/BuildingMenu")
		ui.open_for_slot(self)
	else:
		current_building.call("open_ui")

func assign_building(building: Node3D):
	current_building = building
	build_position.add_child(building)
	if visual_mesh:
		visual_mesh.visible = false
