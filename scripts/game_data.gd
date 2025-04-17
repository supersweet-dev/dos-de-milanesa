extends Node

var final_score = 0
const OrderFunctions = preload("res://scripts/order_functions.gd")

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


# var clients: Array[Texture2D] = [
# 	preload("res://assets/clients/cat-sketch.svg"),
# 	preload("res://assets/clients/chameleon-sketch.svg"),
# 	preload("res://assets/clients/mammoth-sketch.svg"),
# 	preload("res://assets/clients/xolo-sketch.svg"),
# 	#preload("res://assets/clients/percy-debug-full.svg")
# ]
const clients: Dictionary = {
	"cat": {
		"name": "cat",
		"texture": preload("res://assets/clients/cat-sketch.svg"),
		"ingredient_preferences": ["queso_amarillo", "jamon"],
		"order_min": 2,
		"order_max": 4,
		"tip_amount": 2,
		"wait_time": 20,
		"order_evaluation": Callable(OrderFunctions, "_standard_order_check"),
	},
	"chameleon": {
		"name": "chameleon",
		"texture": preload("res://assets/clients/chameleon-sketch.svg"),
		"ingredient_preferences": ["queso_amarillo", "jamon", "frijoles_negros"],
		"order_min": 3,
		"order_max": 5,
		"tip_amount": 4,
		"wait_time": 10,
		"order_evaluation": Callable(OrderFunctions, "_standard_order_check"),
	},
	"mammoth": {
		"name": "mammoth",
		"texture": preload("res://assets/clients/mammoth-sketch.svg"),
		"ingredient_preferences": ["queso_amarillo", "jamon", "frijoles_negros"],
		"order_min": 6,
		"order_max": 6,
		"tip_amount": 8,
		"wait_time": 45,
		"order_evaluation": Callable(OrderFunctions, "_mammoth_order_check"),
	},
	"xolo": {
		"name": "xolo",
		"texture": preload("res://assets/clients/xolo-sketch.svg"),
		"ingredient_preferences": [],
		"order_min": 1,
		"order_max": 4,
		"tip_amount": 1,
		"wait_time": 60,
		"order_evaluation": Callable(OrderFunctions, "_xolo_order_check"),
	},

}
func get_random_order(ingredient_keys: Array, order_min: int, order_max: int) -> Array:
	var available_ingredients = ingredient_keys if ingredient_keys.size() else ["queso_amarillo"]
	var order_size = randi_range(order_min, order_max)
	var order = []
	for i in range(order_size):
		var random_index = randi() % available_ingredients.size()
		order.append(available_ingredients[random_index])
	return order
