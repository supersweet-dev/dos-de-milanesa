extends Node2D

@export var ingredient_textures: Array[Texture2D]  # Assign your 3 ingredient images here
var ingredient_index: int = 0
var current_sandwich: Array[Texture2D] = []  # Stores selected ingredients

@onready var previous_sprite = $PreviousIngredient
@onready var current_sprite = $CurrentIngredient
@onready var next_sprite = $NextIngredient

func _ready():
	_update_display()

func _update_display():
	# Ensure list wraps around
	var total = ingredient_textures.size()
	previous_sprite.texture = ingredient_textures[(ingredient_index - 1 + total) % total]
	current_sprite.texture = ingredient_textures[ingredient_index]
	next_sprite.texture = ingredient_textures[(ingredient_index + 1) % total]

func _process(_delta):
	if Input.is_action_just_pressed("ingredients_up"):
		ingredient_index = (ingredient_index - 1) % ingredient_textures.size()
		_update_display()
	
	elif Input.is_action_just_pressed("ingredients_down"):
		ingredient_index = (ingredient_index + 1) % ingredient_textures.size()
		_update_display()

	elif Input.is_action_just_pressed("ingredients_add"):
		current_sandwich.append(ingredient_textures[ingredient_index])
		print("Added:", ingredient_textures[ingredient_index].resource_path)
