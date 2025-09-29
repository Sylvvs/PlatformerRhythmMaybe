extends CharacterBody2D

const SPEED_ACC = 25
const SPEED_MAX = 100
const JUMP_FORCE = -175
const GRAVITY = 7

# Dash
const DASH_SPEED = 300
const DASH_TIME = 0.20

var dashes := 1
var dash_timer := DASH_TIME
var dash_dir := Vector2.ZERO

var last_x_dir := 0
var last_y_dir := 0

@onready var animation_tree = $AnimationTree

func _physics_process(delta: float) -> void:
	var input_vec := get_input_vector()
	
	if dash_timer >= DASH_TIME:
		if input_vec.x == -1:
			if velocity.x > -SPEED_MAX: velocity.x -= SPEED_ACC
		elif velocity.x < 0: velocity.x += SPEED_ACC
		if input_vec.x == 1:
			if velocity.x < SPEED_MAX: velocity.x += SPEED_ACC
		elif velocity.x > 0: velocity.x -= SPEED_ACC

	if is_on_floor() and dash_timer >= DASH_TIME:
		var friction = SPEED_ACC
		if velocity.x > SPEED_MAX:
			velocity.x = min(velocity.x - friction, SPEED_MAX)
		elif velocity.x < -SPEED_MAX:
			velocity.x = max(velocity.x + friction, -SPEED_MAX)
	print(velocity.x)


	if Input.is_action_just_pressed("jump") and is_on_floor():
		animation_tree["parameters/conditions/idle"] = false
		animation_tree["parameters/conditions/jumping"] = true
		animation_tree["parameters/conditions/dashing"] = false
		velocity.y = JUMP_FORCE
		dash_timer = DASH_TIME
	if Input.is_action_just_released("jump") and velocity.y < 0 and dash_timer >= DASH_TIME:
		velocity.y = 0


	if Input.is_action_just_pressed("dash") and dashes > 0 and dash_timer >= DASH_TIME:
		animation_tree["parameters/conditions/dashing"] = true
		dashes -= 1
		dash_timer = 0.0
		velocity = Vector2.ZERO
		dash_dir = input_vec
		if dash_dir == Vector2.ZERO:
			if velocity.x != 0:
				dash_dir = Vector2(sign(velocity.x), 0)
			else:
				dash_dir = Vector2.RIGHT
		dash_dir = dash_dir.normalized()
		velocity += dash_dir * DASH_SPEED

	if dash_timer < DASH_TIME:
		dash_timer += delta
		if dash_timer >= DASH_TIME:
			velocity = Vector2.ZERO
			dash_timer = DASH_TIME
			animation_tree["parameters/conditions/dashing"] = false

	if dash_timer >= DASH_TIME and !is_on_floor():
		velocity.y += GRAVITY 
		 
	if dash_timer >= DASH_TIME and is_on_floor():
		dashes = 1

	move_and_slide()
	
	if is_on_floor():
		animation_tree["parameters/conditions/jumping"] = false

	if abs(velocity.x) > 0 and is_on_floor():
		pass
		animation_tree["parameters/conditions/running"] = true
		animation_tree["parameters/conditions/idle"] = false
	elif is_on_floor():
		animation_tree["parameters/conditions/running"] = false
		animation_tree["parameters/conditions/idle"] = true
func get_input_vector() -> Vector2:
	last_x_dir = get_axis_dir("walk_left", "walk_right", last_x_dir)
	last_y_dir = get_axis_dir("up", "down", last_y_dir)
	return Vector2(last_x_dir, last_y_dir)

func get_axis_dir(neg_action: String, pos_action: String, last_dir: int) -> int:
	if Input.is_action_just_pressed(neg_action):
		last_dir = -1
	elif Input.is_action_just_pressed(pos_action):
		last_dir = 1

	elif Input.is_action_just_released(neg_action):
		if Input.is_action_pressed(pos_action):
			last_dir = 1
		else:
			last_dir = 0
	elif Input.is_action_just_released(pos_action):
		if Input.is_action_pressed(neg_action):
			last_dir = -1
		else:
			last_dir = 0

	return last_dir

func get_global_rect() -> Rect2:
	var shape = $Hitbox.shape as RectangleShape2D
	return Rect2(global_position - shape.extents, shape.extents * 2.0)
#
