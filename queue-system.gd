extends Node2D
var lane_width: int = 160
var first_lane: int = 256
@export var lanes: Array[int] = [first_lane, first_lane + (lane_width * 1), first_lane + (lane_width * 2), first_lane + (lane_width * 3), first_lane + (lane_width * 4)]  # X positions of lanes
@export var client_scene: PackedScene = preload("res://client.tscn")
@export var spawn_area_y: int = 380  # Starting Y position for new clients
@export var max_clients_per_lane: int = 3
@export var player: CharacterBody2D

var queues: Dictionary = {}

func _ready():
	player = get_node("../MiggyPiggy") 
	for lane in lanes:
		queues[lane] = []  # Initialize lane queues
	_spawn_client()  # Start the spawning cycle

func _spawn_client():
	var lane = lanes[randi() % lanes.size()]
	if queues[lane].size() < max_clients_per_lane:
		var client = client_scene.instantiate()
		client.position = Vector2(lane, spawn_area_y - (queues[lane].size() * 80))
		# Darken based on queue position
		var sprite = client.get_node("Cat-sketch")
		var darkness_factor = 1.0 - (queues[lane].size() * 0.2)  # Reduce brightness per position
		sprite.modulate = Color(darkness_factor, darkness_factor, darkness_factor)

		add_child(client)
		client.get_parent().move_child(client, 0)  # Moves it to the first position in the child list
		queues[lane].append(client)
	
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
			var sprite = remaining_client.get_node("Cat-sketch")  # Adjust if necessary
			var darkness_factor = 1.0 - (i * 0.2)  # Adjust brightness based on new index
			sprite.modulate = Color(darkness_factor, darkness_factor, darkness_factor)

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
