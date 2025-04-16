extends CharacterBody2D

@export var max_speed: float = Globals.MAX_SPEED
@export var accel: float = Globals.ACCEL
@export var friction: float = Globals.FRICTION
@export var bounce_damp: float = Globals.BOUNCE_DAMP # 0 = full reversal, 1 = no bounce

var previous_velocity := Vector2.ZERO

func _physics_process(delta: float):
	var input_direction = 0.0
	if Input.is_action_pressed("move_left"):
		input_direction -= 1
	if Input.is_action_pressed("move_right"):
		input_direction += 1

	# Apply acceleration or friction
	if input_direction != 0:
		velocity.x += input_direction * accel * delta
	else:
		if abs(velocity.x) > 10:
			velocity.x -= sign(velocity.x) * friction * delta
		else:
			velocity.x = 0

	# Clamp max speed
	velocity.x = clamp(velocity.x, -max_speed, max_speed)
	velocity.y = 0

	# Store velocity *before* movement for bounce calculation
	previous_velocity = velocity

	move_and_slide()

	# Handle bounce
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		if abs(collision.get_normal().x) > 0.9:
			# Bounce in X direction based on speed and damp factor
			var impact_speed = previous_velocity.x
			velocity.x = - impact_speed * (1.0 - bounce_damp)
