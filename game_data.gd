extends Node

var ingredients: Array[Texture2D] = [
	preload("res://ingredients/beans.svg"),
	preload("res://ingredients/cheese.svg"),
	preload("res://ingredients/ham.svg")
]

var clients: Array[Texture2D] = [
	preload("res://clients/cat-sketch.svg"),
	preload("res://clients/chameleon-sketch.svg"),
	preload("res://clients/mammoth-sketch.svg"),
	preload("res://clients/xolo-sketch.svg")
]

func get_random_order():
	var order_size = randi_range(1, 6)
	var order = []
	for i in range(order_size):
		order.append(ingredients[randi() % ingredients.size()])
	return order
