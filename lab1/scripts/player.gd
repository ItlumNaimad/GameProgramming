# FILE: Paddle/Paddle.gd
extends CharacterBody2D

# These variables will show up in the editor!
@export var speed = 400
@export var up_action = "ui_up"
@export var down_action = "ui_down"

# This function runs once when the paddle is created.
func _ready():
	# Add this paddle to a group called "paddles". We'll use this later.
	add_to_group("paddles")

# This function runs every single physics frame. Perfect for movement!
func _physics_process(delta):
	var direction = 0
	if Input.is_action_pressed(up_action):
		direction = -1 # In 2D, negative Y is up
	elif Input.is_action_pressed(down_action):
		direction = 1 # Positive Y is down
	
	# Set our vertical velocity
	velocity.y = direction * speed
	
	# This is the Godot function that actually moves our character
	move_and_collide(Vector2(0, velocity.y * delta))

	# Stop the paddle from going off-screen
	var screen_size = get_viewport_rect().size
	var paddle_height = 32 # The height of our paddle
	position.y = clamp(position.y, paddle_height / 2, screen_size.y - (paddle_height / 2))
