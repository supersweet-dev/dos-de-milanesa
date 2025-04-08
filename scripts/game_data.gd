extends Node

var final_score = 0

const ingredients: Dictionary = {
	"frijoles_negros": {
		"name": "frijoles negros",
		"texture": preload("res://assets/ingredients/beans.svg"),
		"price": 1,
		"tags": ["bean", "vegetable"],
	},
	"queso_amarillo": {
		"name": "queso amarillo",
		"texture": preload("res://assets/ingredients/cheese.svg"),
		"price": 1,
		"tags": ["dairy"],
	},
	"jamon": {
		"name": "jamón",
		"texture": preload("res://assets/ingredients/ham.svg"),
		"price": 1,
		"tags": ["meat", "pork"],
	}
}


var clients: Array[Texture2D] = [
	preload("res://assets/clients/cat-sketch.svg"),
	preload("res://assets/clients/chameleon-sketch.svg"),
	preload("res://assets/clients/mammoth-sketch.svg"),
	preload("res://assets/clients/xolo-sketch.svg"),
	#preload("res://assets/clients/percy-debug-full.svg")
]

func get_random_order():
	var order_size = randi_range(1, 6)
	var order = []
	for i in range(order_size):
		order.append(ingredients.keys()[randi() % ingredients.size()])
	return order
