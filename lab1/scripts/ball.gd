# FILE: Ball/Ball.gd
extends CharacterBody2D

# This is like an alarm the ball can send out.
signal out_of_bounds
signal player_scored # NOWY SYGNAŁ
signal ai_scored     # NOWY SYGNAŁ
# The speed of the ball.
@export var speed = 500
#  How much does the movement of the paddle affect the bounce? 0.0 - not at all, 1.0 - very much.
@export var paddle_influence = 0.3
@export var min_horizontal_ratio = 0.1 # 10% prędkości musi być na osi X
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
	#if position.x < 0 or position.x > get_viewport_rect().size.x:
		#out_of_bounds.emit() # Sound the alarm!
		#start() # Reset the ball
	#
	# Check if the ball went off the top or bottom edge
	#if position.y < 0 or position.y > get_viewport_rect().size.y:
		#start() # Just reset it for now

	# --- NOWY BLOK: Ochrona przed utknięciem ---
	# Sprawdzamy, czy prędkość pozioma nie jest niebezpiecznie mała
	var current_speed = velocity.length()
	
	# Unikamy dzielenia przez zero na starcie
	if current_speed > 0:
		var min_x_speed = current_speed * min_horizontal_ratio
		
		if abs(velocity.x) < min_x_speed:
			# Wymuś minimalną prędkość poziomą, zachowując kierunek
			velocity.x = min_x_speed * sign(velocity.x) 
			# sign(x) zwraca -1 jeśli x jest ujemne, 1 jeśli dodatnie
			
			# Renormalizujemy wektor, aby utrzymać stałą prędkość
			velocity = velocity.normalized() * current_speed
	# --- KONIEC NOWEGO BLOKU ---


	# Dopiero teraz ruszamy piłką
	var collision = move_and_collide(velocity * delta)
	if collision:
		# 1. Najpierw obliczamy podstawowe, idealne odbicie
		velocity = velocity.bounce(collision.get_normal())
		var thing_we_hit = collision.get_collider()
		# 2. Sprawdzamy, czy to paletka
		if thing_we_hit.is_in_group("paddles"):
			
			# 3. Pobieramy prędkość paletki. 
			# Jest szybszy i bezpieczniejszy od get(), bo wiemy, że obiekt jest w grupie "paddles".
			var paddle_velocity = thing_we_hit.velocity
			
			# 4. Dodajemy część pionowej prędkości paletki do prędkości piłki.
			#    To jest kluczowa linia!
			velocity.y += paddle_velocity.y * paddle_influence

			# 5. Zwiększamy prędkość i upewniamy się, że piłka nie zwolniła
			#    po dodaniu "podkręcenia". Normalizujemy wektor i mnożymy przez nową prędkość.
			current_speed = velocity.length()
			var new_speed = current_speed * 1.05 # Zwiększamy o 5%
			# Ustawiamy nową prędkość, zachowując nowy kierunek
			velocity = velocity.normalized() * new_speed

func _on_ai_side_body_entered(body: Node2D) -> void:
	# Piłka wpadła do bramki AI, więc gracz zdobywa punkt
	if body == self:
		player_scored.emit()
		start() # Resetuj piłkę

func _on_player_side_body_entered(body: Node2D) -> void:
	# Piłka wpadła do bramki Gracza, więc AI zdobywa punkt
	if body == self:
		ai_scored.emit()
		start() # Resetuj piłkę
