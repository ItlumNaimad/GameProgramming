extends CharacterBody2D 

@onready var ball: CharacterBody2D = $"../ball"

var speed: float = 120
# _process działa 8 razy wolniej niż _physics_process
func _process(delta):
	global_position.y = move_toward(global_position.y, ball.global_position.y, speed*delta)
	move_and_slide()
	
	
