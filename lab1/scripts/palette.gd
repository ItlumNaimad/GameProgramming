extends CharacterBody2D 

@onready var ball: CharacterBody2D = $"../ball"

var speed = 250
var direction_x = 0
var direction_y = 0
# _process działa 8 razy wolniej niż _physics_process
func _physics_process(delta):
	# 1. Określ pozycję docelową (Y piłki)
	var target_y = ball.global_position.y
	
	# 2. Oblicz maksymalny ruch w tej klatce
	var max_step = speed * delta
	
	# 3. Użyj move_toward, aby obliczyć nową pozycję Y.
	#    Funkcja ta przesunie 'global_position.y' w kierunku 'target_y'
	#    o maksymalnie 'max_step', zatrzymując się idealnie na celu.
	var new_y = move_toward(global_position.y, target_y, max_step)
	
	# 4. Oblicz prędkość potrzebną, aby dostać się z obecnej pozycji 
	#    do nowej pozycji w ciągu jednej klatki fizyki (delta).
	#    To jest kluczowy krok, aby velocity odzwierciedlało ruch!
	velocity.y = (new_y - global_position.y) / delta
	
	# 5. Zablokuj oś X
	velocity.x = 0
	
	# 6. Wywołaj move_and_slide(), który użyje obliczonej prędkości
	move_and_slide()
# Stare próby rozwiązania poruszania się
#func _process(delta):
	## przesuwanie paletki z pominięciem fizyki silnika
	#if ball.position.y < global_position.y:
		#direction_y = -1
	#elif ball.position.y > global_position.y:
		#direction_y = 1
	#velocity.y = direction_y * speed
	#move_and_collide(Vector2(0, velocity.y * delta))
	## global_position.y = move_toward(global_position.y, ball.global_position.y, speed*delta)
	
	
	
