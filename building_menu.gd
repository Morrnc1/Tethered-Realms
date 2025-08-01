extends Control

var current_slot: Node = null

func open_for_slot(slot: Node):
	current_slot = slot
	show()

func on_button_pressed(build_type: String):
	var scene_path = "res://Buildings/%s.tscn" % build_type
	var building_scene = load(scene_path)
	var building = building_scene.instantiate()

	if ResourceManager.can_afford(building.build_cost):
		ResourceManager.spend(building.build_cost)
		current_slot.assign_building(building)
		hide()
	else:
		print("Not enough emperial shillings to build " + build_type)

func _ready():
	$LivingQuartersButton.pressed.connect(func(): on_button_pressed("living_quarters"))
	
