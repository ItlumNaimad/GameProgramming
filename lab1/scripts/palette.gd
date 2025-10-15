extends CharacterBody2D 

@onready var ball: CharacterBody2D = $"../ball"

var speed: float = 180
# _process działa 8 razy wolniej niż _physics_process
func _physics_process(delta):
	# przesuwanie paletki z pominięciem fizyki silnika
	global_position.y = move_toward(global_position.y, ball.global_position.y, speed*delta)
	
	
