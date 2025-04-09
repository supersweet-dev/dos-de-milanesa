extends Node2D

enum MoodState {CALM, IMPATIENT, PANIC}

var order: Array = []
var order_checker: Callable
var tip_amount: int = 0
var max_wait_time: float = 0.0
var spawn_time: float = 0.0
var current_mood: MoodState = MoodState.CALM
var shake_intensity: float = 0.0
var base_position: Vector2 # Tracks queue position without shake
var shake_offset: Vector2 = Vector2.ZERO # Tracks current shake displacement

func _ready():
	# Set up shake timer
	var shake_timer = Timer.new()
	shake_timer.wait_time = 0.05
	shake_timer.autostart = true
	shake_timer.timeout.connect(_update_shake)
	add_child(shake_timer)

func update_base_position(new_position: Vector2):
	base_position = new_position
	_apply_position()

func _apply_position():
	position = base_position + shake_offset

func _update_shake():
	if shake_intensity > 0:
		shake_offset = Vector2(
			randf_range(-shake_intensity, shake_intensity),
			randf_range(-shake_intensity * 0.5, shake_intensity * 0.5)
		)
		_apply_position()

func update_mood(current_time: float):
	var remaining = get_remaining_time(current_time)
	var progress = 1.0 - (remaining / max_wait_time)

	if progress >= 0.75: # Last quarter
		if current_mood != MoodState.PANIC:
			current_mood = MoodState.PANIC
			shake_intensity = 8.0
	elif progress >= 0.5: # Second half
		if current_mood != MoodState.IMPATIENT:
			current_mood = MoodState.IMPATIENT
			shake_intensity = 2.0
	else:
		current_mood = MoodState.CALM
		shake_intensity = 0.0
		shake_offset = Vector2.ZERO
		_apply_position()

func set_max_wait_time(wait_time: float):
	max_wait_time = wait_time

func get_remaining_time(current_time: float) -> float:
	return max(0.0, max_wait_time - (current_time - spawn_time))

func set_order(new_order: Array):
	order = new_order

func set_checker(checker: Callable):
	order_checker = checker

func set_tip(tip: int):
	tip_amount = tip

func set_spawn_time(time: float):
	spawn_time = time
