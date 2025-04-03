extends Node

var final_score = 0

var ingredients: Array[Texture2D] = [
	preload("res://assets/ingredients/beans.svg"),
	preload("res://assets/ingredients/cheese.svg"),
	preload("res://assets/ingredients/ham.svg")
]

var clients: Array[Texture2D] = [
	preload("res://assets/clients/cat-sketch.svg"),
	preload("res://assets/clients/chameleon-sketch.svg"),
	preload("res://assets/clients/mammoth-sketch.svg"),
	preload("res://assets/clients/xolo-sketch.svg")
]

func get_random_order():
	var order_size = randi_range(1, 6)
	var order = []
	for i in range(order_size):
		order.append(ingredients[randi() % ingredients.size()])
	return order
