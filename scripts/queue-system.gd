extends Node2D

@export var lane_total = Globals.LANE_TOTAL
@export var lanes: Array[int] = []
@export var client_scene: PackedScene = preload("res://scenes/client.tscn")
@export var spawn_area_y: int = Globals.CLIENT_SPAWN_AREA_Y
@export var max_clients_per_lane: int = Globals.MAX_CLIENTS_PER_LANE

@onready var player: CharacterBody2D = get_node("../MiggyPiggy")
@onready var ingredient_menu = $"../IngredientsMenu"
@onready var game_timer_container = $"../RoundTimer"
@onready var game_timer = $"../RoundTimer/GameTimer"
@onready var timer_pie = $"../RoundTimer/GameTimer/TimerPie"
@onready var score_label = $"../Score"

var TIME_LIMIT = Globals.TIME_LIMIT

const ENABLED_CLIENTS = {
	"cat": {"weight": 5},
	"chameleon": {"weight": 3},
	"mammoth": {"weight": 1},
	"xolo": {"weight": 2}
	}
var client_pool = []

const INGREDIENTS = GameData.ingredients
var INGREDIENT_KEYS = GameData.ingredients.keys()
var BUBBLE_TEXTURE = Globals.BUBBLE_TEXTURE
var CLIENT_VERTICAL_SPACING = Globals.CLIENT_VERTICAL_SPACING
var CLIENT_DARKNESS_FACTOR = Globals.CLIENT_DARKNESS_FACTOR
var INGREDIENT_SCALE = Globals.INGREDIENT_SCALE
var score: int = 0
var starting_timer_position = 0.0
var timer_shake_timer: float = 0.0
var timer_shake_intensity: float = Globals.TIMER_SHAKE_HURRY
var queues: Dictionary = {}
var lane_nodes: Dictionary = {}
var locked_lanes := {}
var timeout_timer: Timer
func _build_client_pool():
	client_pool.clear()
	for client_key in ENABLED_CLIENTS.keys():
		for i in range(ENABLED_CLIENTS[client_key].weight):
			client_pool.append(client_key)
	client_pool.shuffle()
func _ready():
	starting_timer_position = game_timer_container.position.y
	_build_client_pool()
	for i in range(lane_total):
		var lane_node_path = "../OrderLanes/Lane" + str(i + 1)
		var lane_node = get_node(lane_node_path)
		lanes.append(int(lane_node.global_position.x))
		lane_nodes[lanes[i]] = lane_node
	_update_score_display(score)
	game_timer.wait_time = TIME_LIMIT
	timer_pie.max_value = TIME_LIMIT
	timer_pie.value = TIME_LIMIT
	game_timer.timeout.connect(_on_game_timer_timeout)
	game_timer.start()
	for lane in lanes:
		queues[lane] = [] # Initialize lane queues
	ingredient_menu.torta_submitted.connect(_on_torta_submitted)
	ingredient_menu.torta_trashed.connect(_on_torta_trashed)
	timeout_timer = Timer.new()
	timeout_timer.wait_time = 1.0 # Check every second
	timeout_timer.autostart = true
	timeout_timer.timeout.connect(_check_client_timeouts)
	add_child(timeout_timer)
	_spawn_client() # Start the spawning cycle

func _on_game_timer_timeout():
	_show_final_score()

func _show_final_score():
	GameData.final_score = score
	get_tree().change_scene_to_file("res://scenes/screens/score.tscn")

func client_delivery_animation(client: Node2D, order_score: int) -> void:
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)

	var original_position = client.position

	# === Score label setup ===
	var client_score_label = Label.new()
	client_score_label.text = ("+" if order_score >= 0 else "") + str(order_score)

	# Set label colors with outline
	var text_color = Color.GREEN if order_score > 0 else Color.RED
	client_score_label.add_theme_color_override("font_color", text_color)
	client_score_label.add_theme_color_override("font_outline_color", Color.BLACK)
	client_score_label.add_theme_constant_override("outline_size", 4)

	client_score_label.position = Vector2(40, -240)
	client_score_label.z_index = 100

	# Make label more visible
	var font = client_score_label.get_theme_default_font()
	if font:
		client_score_label.add_theme_font_override("font", font)
	client_score_label.add_theme_font_size_override("font_size", 24)

	client.add_child(client_score_label)
	client_score_label.visible = true

	# === Animation for both client and label ===
	if order_score > 0:
		var hop_height = 20.0
		var hop_time = 0.15

		tween.tween_property(client, "position:y", original_position.y - hop_height, hop_time)
		tween.tween_property(client, "position:y", original_position.y, hop_time)
	else:
		var shake_amount = 10.0
		var shake_time = 0.05

		tween.tween_property(client, "position:x", original_position.x - shake_amount, shake_time)
		tween.tween_property(client, "position:x", original_position.x + shake_amount, shake_time)
		tween.tween_property(client, "position:x", original_position.x, shake_time)

	# Add combined animations
	tween.parallel().tween_property(client_score_label, "position:y", client_score_label.position.y - 30, 0.3)
	tween.parallel().tween_property(client_score_label, "modulate:a", 0.0, 0.3).set_delay(0.1)

	# Add client fade out
	tween.parallel().tween_property(client, "modulate:a", 0.0, 0.3).set_delay(0.1)

	await tween.finished

	# Clean up
	client_score_label.queue_free()


func _on_torta_submitted(torta: Array):
	var closest_lane = _get_closest_lane(player.position.x)
	if locked_lanes.has(closest_lane):
		return # Lane is locked, do not proceed

	locked_lanes[closest_lane] = true

	var unlock = func(): locked_lanes.erase(closest_lane)

	if queues[closest_lane].size() > 0:
		var front_client = queues[closest_lane][0]
		var expected_order = front_client.order

		var order_score = 0
		if is_instance_valid(front_client):
			order_score = front_client.order_checker.call(expected_order, torta, front_client.tip_amount)
			score += order_score
			# Animate only if still valid
			if is_instance_valid(front_client):
				await client_delivery_animation(front_client, order_score)

		_update_score_display(score)

		# Dismiss only if still in queue
		if is_instance_valid(front_client) and queues[closest_lane].has(front_client):
			dismiss_client_from_lane(closest_lane, 0)
	else:
		_apply_penalty(torta)

	unlock.call()
func _on_torta_trashed(torta: Array):
	_apply_penalty(torta)

func _update_score_display(new_score: int):
	if score_label:
		score_label.text = "Total:\n$" + str(new_score)

func _apply_penalty(trashed_torta: Array):
	# Calculate penalty based on the number of ingredients in the torta
	var penalty = 0
	for ingredient in trashed_torta:
		if ingredient in INGREDIENT_KEYS:
			penalty += INGREDIENTS[ingredient].price
	score -= penalty
	_update_score_display(score)

	# Show penalty feedback on player
	_show_penalty_feedback(penalty)

func _show_penalty_feedback(penalty: int):
	if penalty == 0: return
	var penalty_label = Label.new()
	penalty_label.text = "-$%d" % penalty
	penalty_label.modulate = Color.RED
	penalty_label.z_index = 100

	# Add black outline for visibility
	penalty_label.add_theme_color_override("font_color", Color.RED)
	penalty_label.add_theme_color_override("font_outline_color", Color.BLACK)
	penalty_label.add_theme_constant_override("outline_size", 4)

	# Position above player's head
	penalty_label.position = Vector2(60, -246) # Adjust these values as needed

	# Make label visible
	var font = penalty_label.get_theme_default_font()
	if font:
		penalty_label.add_theme_font_override("font", font)
	penalty_label.add_theme_font_size_override("font_size", 24)

	player.add_child(penalty_label)

	# Animate the label
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(penalty_label, "position:y", penalty_label.position.y - 30, 0.3)
	tween.tween_property(penalty_label, "modulate:a", 0.0, 0.3)

	await tween.finished
	penalty_label.queue_free()

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
			ingredient_sprite.texture = INGREDIENTS[order[i]].texture
			ingredient_sprite.scale = INGREDIENT_SCALE

			# Calculate position in grid
			var col = i % columns
			var row = floor(i / columns)
			var x_pos = start_x + col * horizontal_spacing
			var y_pos = start_y + row * vertical_spacing + 15

			ingredient_sprite.position = Vector2(x_pos, y_pos)
			order_container.add_child(ingredient_sprite)

func get_weighted_client_key() -> String:
	return client_pool[randi() % client_pool.size()] if client_pool.size() > 0 else "cat"

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
		var client_type = GameData.clients[get_weighted_client_key()]

		# Set client properties
		client.position = Vector2(lane, spawn_area_y - (queue.size() * CLIENT_VERTICAL_SPACING))
		var client_order = GameData.get_random_order(client_type.ingredient_preferences, client_type.order_min, client_type.order_max)
		client.set_order(client_order)
		client.set_checker(client_type.order_evaluation)
		client.set_tip(client_type.tip_amount)
		client.set_max_wait_time(client_type.wait_time) # wait_time is in seconds
		client.set_spawn_time(Time.get_ticks_msec() / 1000.0)
		var new_y = spawn_area_y - (queue.size() * CLIENT_VERTICAL_SPACING)
		client.update_base_position(Vector2(lane, new_y))

		# Set visual properties
		var sprite = client.get_node("ClientSprite")
		sprite.texture = client_type.texture
		var darkness_factor = 1.0 - (queue.size() * CLIENT_DARKNESS_FACTOR)
		sprite.modulate = Color(darkness_factor, darkness_factor, darkness_factor)

		add_child(client)
		move_child(client, 0)
		queue.append(client)
		_update_order_display(lane)

	# Calculate next spawn time based on game progress
	var time_remaining_ratio = game_timer.time_left / TIME_LIMIT
	var spawn_interval: float
	var spawn_variation: float
	if time_remaining_ratio <= 0.35:
		spawn_interval = Globals.SPAWN_INTERVAL * 0.2
		spawn_variation = Globals.SPAWN_VARIATION * 0.2
	elif time_remaining_ratio <= 0.85:
		spawn_interval = Globals.SPAWN_INTERVAL * 0.5
		spawn_variation = Globals.SPAWN_VARIATION * 0.5
	else:
		spawn_interval = Globals.SPAWN_INTERVAL
		spawn_variation = Globals.SPAWN_VARIATION
	# Schedule next spawn with random variation
	var spawn_wait = spawn_interval + randf_range(-spawn_variation, spawn_variation)
	await get_tree().create_timer(spawn_wait).timeout
	_spawn_client()
# Modified to handle dismissing any client from any position in the queue
func dismiss_client_from_lane(lane: int, index: int):
	var queue = queues[lane]
	if index >= 0 and index < queue.size():
		var client = queue[index]
		client.queue_free()
		queue.remove_at(index)

		# Reposition remaining clients
		for i in range(queue.size()):
			var new_y = spawn_area_y - (i * CLIENT_VERTICAL_SPACING)
			queue[i].update_base_position(Vector2(lane, new_y))

			# Update darkness factor
			var sprite = queue[i].get_node("ClientSprite")
			var darkness_factor = 1.0 - (i * CLIENT_DARKNESS_FACTOR)
			sprite.modulate = Color(darkness_factor, darkness_factor, darkness_factor)

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


func _check_client_timeouts():
	var current_time = Time.get_ticks_msec() / 1000.0

	for lane in lanes:
		var queue = queues[lane]
		for i in range(queue.size() - 1, -1, -1):
			var client = queue[i]
			client.update_mood(current_time) # Update mood state
			if client.get_remaining_time(current_time) <= 0:
				await _timeout_fade(client) # Wait for fade animation
				dismiss_client_from_lane(lane, i)

func _timeout_fade(client: Node2D) -> void:
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(client, "modulate:a", 0.0, 0.2) # 0.3 second fade
	await tween.finished

func _process(delta):
	if game_timer and timer_pie:
		timer_pie.value = game_timer.time_left

		# Shaking logic
		var remaining_time = game_timer.time_left
		var time_ratio = remaining_time / TIME_LIMIT

		if time_ratio <= 0.25:
			timer_shake_timer += delta
			var shake_intensity = timer_shake_intensity
			timer_pie.modulate = Color(1, 0.7, 0.8) # Light pink
			if time_ratio <= 0.10:
				shake_intensity *= 2.0
				timer_pie.modulate = Color(0.8, 0.4, 0.4) # Saturated red
			var shake_offset = Vector2(randf_range(-shake_intensity, shake_intensity), randf_range(-shake_intensity, shake_intensity))
			game_timer_container.position.y = starting_timer_position + shake_offset.y
		else:
			game_timer_container.position.y = starting_timer_position
