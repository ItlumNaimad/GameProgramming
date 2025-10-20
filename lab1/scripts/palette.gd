extends CharacterBody2D 

@onready var ball: CharacterBody2D = $"../ball"

var speed = 180
var direction_x = 0
var direction_y = 0
# _process działa 8 razy wolniej niż _physics_process
func _physics_process(delta):
	# przesuwanie paletki z pominięciem fizyki silnika
	if ball.position.y < global_position.y:
		direction_y = -1
	elif ball.position.y > global_position.y:
		direction_y = 1
	velocity.y = direction_y * speed
	move_and_collide(Vector2(0, velocity.y * delta))
	# global_position.y = move_toward(global_position.y, ball.global_position.y, speed*delta)
	
	
	
