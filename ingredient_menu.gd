extends Node2D

@export var ingredient_textures: Array[Texture2D]  # Assign ingredient images here
@onready var torta_container = $"../TortaContainer"  # Reference to the torta area

var ingredient_index: int = 0
var current_torta: Array[Texture2D] = []  # Tracks selected ingredients

@onready var previous_sprite = $PreviousIngredient
@onready var current_sprite = $CurrentIngredient
@onready var next_sprite = $NextIngredient

func _ready():
	_update_display()

func _update_display():
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
		_add_ingredient_to_torta(ingredient_textures[ingredient_index])

func _add_ingredient_to_torta(texture: Texture2D):
	# Create new sprite
	var new_ingredient = Sprite2D.new()
	new_ingredient.texture = texture
	new_ingredient.scale = Vector2(0.08, 0.08) 
	new_ingredient.position = Vector2(0, torta_container.get_child_count() * 40)  # Stack them downwards
	torta_container.add_child(new_ingredient)

	# Track in torta list
	current_torta.append(texture)
	print("Current torta:", current_torta.size(), "ingredients added.")
