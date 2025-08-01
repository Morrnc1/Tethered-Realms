extends Node3D

@export var build_cost: int
@export var upgrade_cost: int
@export var resource_type: String = ""
@export var production_rate: float = 0.0
var level: int = 1

func _process(delta):
	if Engine.is_editor_hint():
		return
	produce_resource(delta)

func produce_resource(delta: float):
	var amount = production_rate * delta
	ResourceManager.add(resource_type, amount)

func upgrade():
	if ResourceManager.can_afford(upgrade_cost):
		ResourceManager.spend(upgrade_cost)
		level += 1
		production_rate *= 1.5

func open_ui():
	print("Open upgrade UI for building")
