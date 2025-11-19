extends RigidBody2D

# Siła "podskoku". Musisz ją dostosować metodą prób i błędów.
# Ponieważ grawitacja ciągnie w dół (wartości dodatnie), impuls musi być UJEMNY.
@export var jump_impulse: float = -400.0

# Flaga, aby zatrzymać grę na starcie, zgodnie z instrukcją
var game_started = false

func _ready():
	# Zatrzymaj fizykę na starcie (odpowiednik Time.timeScale = 0)
	# W Godocie dla RigidBody ustawiamy 'sleeping' na true
	sleeping = true

func _unhandled_input(event):
	# Sprawdź, czy naciśnięto akcję "jump" (którą musisz zdefiniować w Mapie Wejść)
	if event.is_action_pressed("jump"):
		
		if not game_started:
			# Jeśli to pierwszy skok, "obudź" ciało i rozpocznij grę
			sleeping = false
			game_started = true
			# Tutaj możesz też wyemitować sygnał do GameManager,
			# aby uruchomił resztę gry (zgodnie z instrukcją PDF)
		
		# --- GŁÓWNA MECHANIKA ---
		# 1. Najpierw zerujemy aktualną prędkość, aby każdy "flap" był taki sam
		linear_velocity.y = 0
		
		# 2. Zastosuj natychmiastowy impuls w górę
		apply_impulse(Vector2(0, jump_impulse))

# Ta funkcja jest wywoływana, gdy ciało się z czymś zderzy
func _on_body_entered(body):
	# Tutaj będzie logika kolizji, np. restart gry
	# Zgodnie z instrukcją PDF (sekcja 3.3.5)
	print("Kolizja! Koniec gry.")
	# Tutaj wyemituj sygnał do GameManager, aby zrestartował scenę
