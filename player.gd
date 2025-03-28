extends CharacterBody2D

@export var speed: float = 600.0

func _physics_process(_delta: float):
	var direction = 0
	
	if Input.is_action_pressed("move_left"):
		direction = -1
	elif Input.is_action_pressed("move_right"):
		direction = 1
	
	velocity.x = direction * speed
	velocity.y = 0  # Ensuring no vertical movement
	
	move_and_slide()
