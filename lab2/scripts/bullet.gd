extends Area2D

@export var speed: int = 1000

# Ta zmienna BĘDZIE USTAWIONA Z ZEWNĄTRZ przez skrypt,
# który tworzy pocisk. Domyślnie jest zerowa.
var direction: Vector2 = Vector2.ZERO

func _physics_process(delta: float) -> void:
	# Przesuwamy pocisk. Używamy global_position dla Area2D.
	global_position += direction * speed * delta

# Ta funkcja zostanie wywołana, gdy sygnał "body_entered"
# zostanie podłączony do tego skryptu.
func _on_body_entered(body: Node2D) -> void:
	# --- NOWY WARUNEK ---
	# Sprawdź, czy ciało, w które trafiliśmy, NALEŻY do grupy "player".
	if body.is_in_group("player"):
		return # Jeśli tak, zignoruj tę kolizję i nie rób nic.

	# --- RESZTA LOGIKI ---
	# Jeśli kod doszedł tutaj, to znaczy, że trafiliśmy w coś,
	# co NIE JEST graczem (np. wróg, ściana).

	# OPCJONALNIE: Sprawdź, czy to wróg (dodaj wrogów do grupy "enemies")
	if body.is_in_group("enemies"):
	# Zamiast niszczyć wroga, wywołaj na nim funkcję śmierci
		body.die()
# Zniszcz pocisk (bo w coś trafił)
	queue_free()

	# Zniszcz pocisk, bo trafił w coś, co nie jest graczem.
	queue_free()

# Ta funkcja zostanie wywołana, gdy sygnał "screen_exited"
# z węzła VisibleOnScreenNotifier2D zostanie podłączony.
func _on_screen_exited() -> void:
	# Zniszcz pocisk, gdy wyleci poza ekran (dla optymalizacji)
	queue_free()
