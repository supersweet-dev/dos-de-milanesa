extends Node2D

@onready var torta_container = $"../TortaContainer" # Reference to the torta area

var ingredient_index: int = 0
var current_torta: Array[String] = [] # Tracks selected ingredients
signal torta_submitted(torta: Array) # Declare signal

@onready var previous_sprite = $PreviousIngredient
@onready var current_sprite = $CurrentIngredient
@onready var next_sprite = $NextIngredient

var INGREDIENT_KEYS = GameData.ingredients.keys()
const INGREDIENTS = GameData.ingredients
const MAX_INGREDIENTS = 6 # Limit

func _ready():
	_update_display()

func _update_display():
	var total = INGREDIENT_KEYS.size()
	previous_sprite.texture = INGREDIENTS[INGREDIENT_KEYS[(ingredient_index - 1 + total) % total]].texture
	current_sprite.texture = INGREDIENTS[INGREDIENT_KEYS[ingredient_index]].texture
	next_sprite.texture = INGREDIENTS[INGREDIENT_KEYS[(ingredient_index + 1) % total]].texture

func _process(_delta):
	if Input.is_action_just_pressed("ingredients_up"):
		ingredient_index = (ingredient_index - 1) % INGREDIENT_KEYS.size()
		_update_display()
	elif Input.is_action_just_pressed("ingredients_down"):
		ingredient_index = (ingredient_index + 1) % INGREDIENT_KEYS.size()
		_update_display()
	elif Input.is_action_just_pressed("ingredients_add"):
		_add_ingredient_to_torta(INGREDIENT_KEYS[ingredient_index])
	elif Input.is_action_just_pressed("serve_order"):
		_submit_torta()
	elif Input.is_action_just_pressed("trash_order"):
		_clear_torta()

func _add_ingredient_to_torta(key: String):
	if current_torta.size() >= MAX_INGREDIENTS:
		# Limit reached
		return

	# Create new sprite
	var new_ingredient = Sprite2D.new()
	new_ingredient.texture = INGREDIENTS[key].texture
	new_ingredient.scale = Vector2(0.1, 0.1)
	new_ingredient.position = Vector2(0, torta_container.get_child_count() * 40) # Stack them downwards
	torta_container.add_child(new_ingredient)

	# Track in torta list
	current_torta.append(key)

func _submit_torta():
	print("Submitting torta: ", current_torta)
	torta_submitted.emit(current_torta)
	_clear_torta() # Reset after submission

func _clear_torta():
	for child in torta_container.get_children():
		child.queue_free()
	current_torta.clear()
