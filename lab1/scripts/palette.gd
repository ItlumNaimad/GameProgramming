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
	
	# 3. Użyj move_toward, aby obliczyć nową docelową pozycję Y
	var new_y = move_toward(global_position.y, target_y, max_step)
	
	# 4. Oblicz wektor przesunięcia (motion vector)
	# Chcemy się przesunąć z 'global_position.y' do 'new_y'.
	# Oś X pozostaje nietknięta (przesunięcie o 0).
	var motion = Vector2(0, new_y - global_position.y)
	
	# 5. ZASTOSUJ ZMIANĘ:
	# Użyj move_and_collide. Ta funkcja nie będzie się ślizgać.
	move_and_collide(motion)
	
	# 6. Aktualizacja 'velocity' na użytek piłki.
	# Ta linijka jest kluczowa, aby piłka wciąż mogła odczytać 
	# prędkość paletki przy odbiciu (dla podkręcenia).
	# Dzielimy przez delta, aby zamienić 'przesunięcie' z powrotem na 'prędkość'.
	if delta > 0:
		velocity = motion / delta
	else:
		velocity = Vector2.ZERO
		

	
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
	
	
	
