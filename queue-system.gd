extends Node2D
var lane_width: int = 160
var first_lane: int = 256
@export var lanes: Array[int] = [first_lane, first_lane + (lane_width * 1), first_lane + (lane_width * 2), first_lane + (lane_width * 3), first_lane + (lane_width * 4)]
@export var client_scene: PackedScene = preload("res://client.tscn")
@export var spawn_area_y: int = 380
@export var max_clients_per_lane: int = 3
@export var player: CharacterBody2D

var queues: Dictionary = {}

func _ready():
	player = get_node("../MiggyPiggy") 
	for lane in lanes:
		queues[lane] = []  # Initialize lane queues
	_spawn_client()  # Start the spawning cycle
	
func _update_order_display(lane: int):
	var lane_index = lanes.find(lane)  
	if lane_index == -1:
		return  

	var lane_node = get_node("../OrderLanes/Lane" + str(lane_index + 1))

	# Clear existing order display
	for child in lane_node.get_children():
		child.queue_free()

	# Only display if there are clients in the lane
	if queues[lane].size() > 0:
		var front_client = queues[lane][0]
		var order = front_client.order

		# Create sprites for each ingredient
		for i in range(order.size()):
			var ingredient_sprite = Sprite2D.new()
			ingredient_sprite.texture = order[i]

			# Calculate position - second line starts after 3 sprites
			var x_pos = (i % 3) * 40
			var y_pos = 0 if i < 3 else 40

			ingredient_sprite.position = Vector2(x_pos, y_pos)
			ingredient_sprite.scale = Vector2(0.04, 0.04)
			lane_node.add_child(ingredient_sprite)

func _spawn_client():
	# Find available lanes
	var available_lanes = []
	for lane in lanes:
		if queues[lane].size() < max_clients_per_lane:
			available_lanes.append(lane)
	
	if available_lanes.size() > 0:
		# Spawn in a random available lane
		var lane = available_lanes[randi() % available_lanes.size()]
		var client = client_scene.instantiate()
		client.position = Vector2(lane, spawn_area_y - (queues[lane].size() * 80))

		client.set_order(GameData.get_random_order())

		# Darken based on queue position
		var sprite = client.get_node("Cat-sketch")
		var darkness_factor = 1.0 - (queues[lane].size() * 0.2)
		sprite.modulate = Color(darkness_factor, darkness_factor, darkness_factor)

		add_child(client)
		client.get_parent().move_child(client, 0)
		queues[lane].append(client)

		# Update order display
		_update_order_display(lane)

	# Always schedule next spawn attempt, regardless of whether we spawned this time
	await get_tree().create_timer(randf_range(1, 4)).timeout
	_spawn_client()

func dismiss_client(lane: int):
	if queues[lane].size() > 0:
		var client = queues[lane].pop_front()
		client.queue_free()
		
		# Move remaining clients up and update their shading
		for i in range(queues[lane].size()):
			var remaining_client = queues[lane][i]
			remaining_client.position.y += 80  
			
			# Recalculate darkness
			var sprite = remaining_client.get_node("Cat-sketch")
			var darkness_factor = 1.0 - (i * 0.2)
			sprite.modulate = Color(darkness_factor, darkness_factor, darkness_factor)
		
		# Update order display (will clear if lane is now empty)
		_update_order_display(lane)

func _process(_delta):
	if Input.is_action_just_pressed("serve_order"):
		var closest_lane = _get_closest_lane(player.position.x)
		dismiss_client(closest_lane)

func _get_closest_lane(player_x: float) -> int:
	var closest_lane = lanes[0]
	var min_distance = abs(player_x - lanes[0])
	for lane in lanes:
		var distance = abs(player_x - lane)
		if distance < min_distance:
			closest_lane = lane
			min_distance = distance
	return closest_lane
