# FILE: Ball/Ball.gd
extends CharacterBody2D

# This is like an alarm the ball can send out.
signal out_of_bounds

# The speed of the ball.
@export var speed = 500

# This function will reset the ball's position and velocity.
func start():
	# Put the ball in the middle of the screen
	position = get_viewport_rect().size / 2
	
	# Give it a random starting direction
	var direction_x = 1.0 if randf() > 0.5 else -1.0 # Go left or right
	var direction_y = randf_range(-0.5, 0.5) # Go slightly up or down
	
	# Apply the direction and speed. .normalized() keeps the speed consistent.
	velocity = Vector2(direction_x, direction_y).normalized() * speed

# This function is called automatically when the game starts.
func _ready():
	start()

func _physics_process(delta):
	# Check if the ball went off the left or right edge
	if position.x < 0 or position.x > get_viewport_rect().size.x:
		out_of_bounds.emit() # Sound the alarm!
		start() # Reset the ball
	
	# Check if the ball went off the top or bottom edge
	if position.y < 0 or position.y > get_viewport_rect().size.y:
		start() # Just reset it for now

	# Move the ball and check if we hit anything
	var collision = move_and_collide(velocity * delta)
	
	# If we hit something...
	if collision:
		# "bounce" is a handy function that reflects the velocity perfectly
		velocity = velocity.bounce(collision.get_normal())
		
		# Let's make the game harder as it goes on!
		var thing_we_hit = collision.get_collider()
		if thing_we_hit.is_in_group("paddles"):
			velocity *= 1.05 # Increase speed by 5%
