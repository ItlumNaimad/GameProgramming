extends RigidBody2D

# Siła wyskoku. Wartość ujemna, bo w Godocie oś Y w górę to wartości ujemne.
@export var jump_force = -300.0
# Opcjonalnie: maksymalny kąt obrotu przy spadaniu
@export var max_rotation = 30.0

var game_started = false

func _ready():
	# Na starcie wyłączamy fizykę, żeby ptak nie spadł od razu (TimeScale = 0 z instrukcji)
	# freeze = true sprawia, że obiekt wisi w powietrzu
	freeze = true 

func _input(event):
	# Sprawdzamy, czy wciśnięto spację/myszkę (zdefiniuj akcję "jump" w Project Settings -> Input Map)
	if event.is_action_pressed("jump"):
		if not game_started:
			start_game()
		
		jump()

func start_game():
	game_started = true
	freeze = false # Odblokuj fizykę, grawitacja zaczyna działać

func jump():
	# 1. Zerujemy aktualną prędkość pionową. 
	# Bez tego, jeśli spadamy szybko, skok byłby słabszy (musiałby walczyć z pędem w dół).
	linear_velocity.y = 0
	
	# 2. Nadajemy natychmiastowy impuls w górę.
	apply_impulse(Vector2(0, jump_force))

func _physics_process(delta):
	# Opcjonalny efekt: Obracanie ptaka w zależności od prędkości (dziobem w dół jak spada)
	if linear_velocity.y > 0:
		# Spadamy -> obracaj w dół
		rotation_degrees = lerp(rotation_degrees, max_rotation, 5 * delta)
	else:
		# Lecimy w górę -> obracaj w górę
		rotation_degrees = lerp(rotation_degrees, -max_rotation, 5 * delta)

# Funkcja wykrywająca kolizję (wymaga włączenia Contact Monitor w Inspectorze!)
func _on_body_entered(body):
	# Jeśli w coś uderzyliśmy (rura lub ziemia) -> Koniec Gry
	get_tree().reload_current_scene() # Najprostszy restart
