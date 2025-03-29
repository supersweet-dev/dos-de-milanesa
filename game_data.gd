extends Node

var ingredients: Array[Texture2D] = []  # Holds all ingredient textures

func _ready():
	_load_ingredients_from_folder("res://ingredients/")

func _load_ingredients_from_folder(folder_path: String):
	var dir = DirAccess.open(folder_path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".svg"):  # Add more formats if needed
				var texture = load(folder_path + file_name) as Texture2D
				if texture:
					ingredients.append(texture)
			file_name = dir.get_next()
		print("Loaded ingredients:", ingredients.size())

func get_random_order():
	var order_size = randi_range(1, 6)
	var order = []
	for i in range(order_size):
		order.append(ingredients[randi() % ingredients.size()])
	return order
