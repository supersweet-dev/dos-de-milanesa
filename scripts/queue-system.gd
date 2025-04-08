extends Node2D

@export var lane_total = 5
@export var lanes: Array[int] = []
@export var client_scene: PackedScene = preload("res://scenes/client.tscn")
@export var spawn_area_y: int = 620
@export var max_clients_per_lane: int = 3

@onready var player: CharacterBody2D = get_node("../MiggyPiggy")
@onready var ingredient_menu = $"../IngredientsMenu"
@onready var game_timer = $"../GameTimer"
@onready var score_label = $"../Score"

const BUBBLE_TEXTURE = preload("res://assets/game-ui/bubble.svg")
const CLIENT_VERTICAL_SPACING = 180
const CLIENT_DARKNESS_FACTOR = 0.2
const INGREDIENT_SCALE = Vector2(0.08, 0.08)
var score: int = 0
var queues: Dictionary = {}
var lane_nodes: Dictionary = {}

func _ready():
	for i in range(lane_total):
		var lane_node_path = "../OrderLanes/Lane" + str(i + 1)
		var lane_node = get_node(lane_node_path)
		lanes.append(int(lane_node.global_position.x))
		lane_nodes[lanes[i]] = lane_node
	_update_score_display(score)
	game_timer.timeout.connect(_on_game_timer_timeout)
	game_timer.start()
	for lane in lanes:
		queues[lane] = [] # Initialize lane queues
	ingredient_menu.torta_submitted.connect(_on_torta_submitted)
	_spawn_client() # Start the spawning cycle
func _on_game_timer_timeout():
	_show_final_score()
func _show_final_score():
	GameData.final_score = score
	get_tree().change_scene_to_file("res://scenes/screens/score.tscn")

func _on_torta_submitted(torta: Array):
	var closest_lane = _get_closest_lane(player.position.x)
	if queues[closest_lane].size() > 0:
		var front_client = queues[closest_lane][0]
		var expected_order = front_client.order

		# Compare order
		if _orders_match(expected_order, torta):
			score += 1
		else:
			score -= 1
		_update_score_display(score)
		dismiss_client(closest_lane)
func _update_score_display(new_score: int):
	if score_label:
		score_label.text = "Puntos:\n" + str(new_score)
func _orders_match(order1: Array, order2: Array) -> bool:
	# Convert both arrays into dictionaries with ingredient counts
	var count1 = _count_ingredients(order1)
	var count2 = _count_ingredients(order2)

	return count1 == count2 # Check if the ingredient counts match

func _count_ingredients(order: Array) -> Dictionary:
	var count = {}
	for ingredient in order:
		if ingredient in count:
			count[ingredient] += 1
		else:
			count[ingredient] = 1
	return count

func _update_order_display(lane: int):
	var lane_index = lanes.find(lane)
	if lane_index == -1:
		return

	var lane_node = lane_nodes.get(lane)
	var queue = queues[lane]

	# Clear existing order display
	for child in lane_node.get_children():
		child.queue_free()

	# Only display if there are clients in the lane
	if queue.size() > 0:
		var front_client = queue[0]
		var order = front_client.order
		var ingredient_count = order.size()

		# Create a container Node2D to hold everything
		var order_container = Node2D.new()
		lane_node.add_child(order_container)

		# Create and add the bubble background sprite
		var bubble_sprite = Sprite2D.new()
		bubble_sprite.texture = BUBBLE_TEXTURE
		order_container.add_child(bubble_sprite)

		# Calculate dynamic positioning
		var bubble_width = 240
		var bubble_height = 180
		var usable_width = bubble_width * 1.2
		var usable_height = bubble_height * 1.4

		# Determine grid dimensions based on ingredient count
		var columns = min(ingredient_count, 3) # Max 3 columns
		var rows = ceil(float(ingredient_count) / columns)

		# Calculate spacing between ingredients
		var horizontal_spacing = usable_width / (columns + 1)
		var vertical_spacing = usable_height / (rows + 1)

		# Calculate starting position (top-left of centered grid)
		var start_x = - usable_width / 2 + horizontal_spacing
		var start_y = - usable_height / 2 + vertical_spacing
		# Create sprites for each ingredient
		for i in range(ingredient_count):
			var ingredient_sprite = Sprite2D.new()
			ingredient_sprite.texture = order[i]
			ingredient_sprite.scale = INGREDIENT_SCALE

			# Calculate position in grid
			var col = i % columns
			var row = floor(i / columns)
			var x_pos = start_x + col * horizontal_spacing
			var y_pos = start_y + row * vertical_spacing + 15

			ingredient_sprite.position = Vector2(x_pos, y_pos)
			order_container.add_child(ingredient_sprite)


func _spawn_client():
	# Find available lanes
	var available_lanes = []
	for lane in lanes:
		if queues[lane].size() < max_clients_per_lane:
			available_lanes.append(lane)

	if available_lanes.size() > 0:
		# Spawn in a random available lane
		var lane = available_lanes[randi() % available_lanes.size()]
		var queue = queues[lane]
		var client = client_scene.instantiate()
		client.position = Vector2(lane, spawn_area_y - (queue.size() * CLIENT_VERTICAL_SPACING))
		client.set_order(GameData.get_random_order())

		var random_texture = GameData.clients[randi() % GameData.clients.size()]
		var sprite = client.get_node("ClientSprite")
		sprite.texture = random_texture
		var darkness_factor = 1.0 - (queue.size() * CLIENT_DARKNESS_FACTOR)
		sprite.modulate = Color(darkness_factor, darkness_factor, darkness_factor)

		add_child(client)
		move_child(client, 0)
		queue.append(client)

		# Update order display
		_update_order_display(lane)

	# Always schedule next spawn attempt, regardless of whether we spawned this time
	await get_tree().create_timer(randf_range(1, 4)).timeout
	_spawn_client()

func dismiss_client(lane: int):
	var queue = queues[lane]
	if queue.size() > 0:
		var client = queue.pop_front()
		client.queue_free()

		# Move remaining clients up and update their shading
		for i in range(queue.size()):
			var remaining_client = queue[i]
			remaining_client.position.y += CLIENT_VERTICAL_SPACING

			# Recalculate darkness
			var sprite = remaining_client.get_node("ClientSprite")
			var darkness_factor = 1.0 - (i * CLIENT_DARKNESS_FACTOR)
			sprite.modulate = Color(darkness_factor, darkness_factor, darkness_factor)

		# Update order display (will clear if lane is now empty)
		_update_order_display(lane)

func _get_closest_lane(player_x: float) -> int:
	var closest_lane = lanes[0]
	var min_distance = abs(player_x - lanes[0])
	for lane in lanes:
		var distance = abs(player_x - lane)
		if distance < min_distance:
			closest_lane = lane
			min_distance = distance
	return closest_lane
