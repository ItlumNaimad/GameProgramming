extends Node2D

# Prędkość przesuwania rur w lewo
@export var speed = 200.0

func _ready():
	# Dodajemy ciała fizyczne rur (StaticBody2D) do grupy "obstacles".
	# To jest kluczowe, aby skrypt ptaka mógł wykryć zderzenie.
	# W scenie pipe.tscn to kształty kolizji były w grupie, a nie ciała - to był błąd.
	$TopPipe/StaticBody2D.add_to_group("obstacles")
	$BottomPipe/StaticBody2D.add_to_group("obstacles")

func _process(delta):
	# Przesuwamy obiekt w lewo w każdej klatce
	position.x -= speed * delta

# Podłącz sygnał "screen_exited" z węzła VisibleOnScreenNotifier2D do tej funkcji
func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free() # Usuń rurę, żeby nie zapychać pamięci

# Podłącz sygnał "body_entered" z ScoreArea do tej funkcji
func _on_score_area_body_entered(body):
	# Sprawdzamy, czy wleciał gracz (zakładając, że ptak nazywa się "Bird")
	if body.name == "Bird":
		# Wywołaj funkcję add_point w głównym skrypcie sceny
		# get_tree().current_scene to węzeł "Main"
		if get_tree().current_scene.has_method("add_point"):
			get_tree().current_scene.add_point()
