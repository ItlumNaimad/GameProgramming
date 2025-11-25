extends Node2D

# Prędkość przesuwania rur w lewo
@export var speed = 200.0

func _process(delta):
	# Przesuwamy obiekt w lewo w każdej klatce
	position.x -= speed * delta

# Podłącz sygnał "screen_exited" z węzła VisibleOnScreenNotifier2D do tej funkcji
func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free() # Usuń rurę, żeby nie zapychać pamięci

# Podłącz sygnał "body_entered" z ScoreArea do tej funkcji
func _on_score_area_body_entered(body):
	if body.name == "Player": # Zakładamy, że gracz nazywa się "Player"
		# Tutaj dodalibyśmy punkty, np. przez GameManagera
		print("Punkt zdobyty!")
