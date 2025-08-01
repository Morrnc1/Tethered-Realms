extends Node

var resource := {
	"mana": 0.0,
	"emperial shillings": 300
}

func can_afford(cost: int) -> bool:
	return resource.get("emperial shillings", 0) >= cost

func spend(amount: int):
	resource["emperial shillings"] -= amount

func add(resource_name: String, amount: float):
	if resource.has(resource_name):
		resource[resource_name] += amount
	else:
		resource[resource_name] = amount

func get_resource(resource_name: String) -> float:
	return resource.get(resource_name, 0)
