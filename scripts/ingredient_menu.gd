extends Node2D

@onready var torta_container = $"../TortaContainer" # Reference to the torta area

var ingredient_index: int = 0
var current_torta: Array[Texture2D] = [] # Tracks selected ingredients
signal torta_submitted(torta: Array) # Declare signal

@onready var previous_sprite = $PreviousIngredient
@onready var current_sprite = $CurrentIngredient
@onready var next_sprite = $NextIngredient

const MAX_INGREDIENTS = 6 # Limit

func _ready():
	_update_display()

func _update_display():
	var total = GameData.ingredients.size()
	previous_sprite.texture = GameData.ingredients[(ingredient_index - 1 + total) % total]
	current_sprite.texture = GameData.ingredients[ingredient_index]
	next_sprite.texture = GameData.ingredients[(ingredient_index + 1) % total]

func _process(_delta):
	if Input.is_action_just_pressed("ingredients_up"):
		ingredient_index = (ingredient_index - 1) % GameData.ingredients.size()
		_update_display()
	elif Input.is_action_just_pressed("ingredients_down"):
		ingredient_index = (ingredient_index + 1) % GameData.ingredients.size()
		_update_display()
	elif Input.is_action_just_pressed("ingredients_add"):
		_add_ingredient_to_torta(GameData.ingredients[ingredient_index])
	elif Input.is_action_just_pressed("serve_order"):
		_submit_torta()
	elif Input.is_action_just_pressed("trash_order"):
		_clear_torta()

func _add_ingredient_to_torta(texture: Texture2D):
	if current_torta.size() >= MAX_INGREDIENTS:
		# Limit reached
		return

	# Create new sprite
	var new_ingredient = Sprite2D.new()
	new_ingredient.texture = texture
	new_ingredient.scale = Vector2(0.1, 0.1)
	new_ingredient.position = Vector2(0, torta_container.get_child_count() * 40) # Stack them downwards
	torta_container.add_child(new_ingredient)

	# Track in torta list
	current_torta.append(texture)

func _submit_torta():
	torta_submitted.emit(current_torta)
	_clear_torta() # Reset after submission

func _clear_torta():
	for child in torta_container.get_children():
		child.queue_free()
	current_torta.clear()
