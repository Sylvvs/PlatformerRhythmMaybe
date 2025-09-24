extends CharacterBody2D

const SPEED_ACC = 20
const SPEED_MAX = 200

const JUMP_FORCE = -200

func _physics_process(_delta: float) -> void:
	up_direction = Vector2(0,-1)
	if Input.is_action_pressed("walk_left"):
		velocity.x = max(velocity.x - SPEED_ACC, -SPEED_MAX)
	elif Input.is_action_pressed("walk_right"):
		velocity.x = min(velocity.x + SPEED_ACC, SPEED_MAX)
	else:
		velocity.x = 0

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_FORCE

	if not is_on_floor():
		velocity.y += 10

	move_and_slide()
