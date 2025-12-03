extends Node

var score = 0
var best_score = 0 # Zmienna na najlepszy wynik

# Zamiast referencji do Labela, bierzemy referencję do całego skryptu UI
@onready var ui = $UI 
@onready var bird = $Bird
@onready var pipe_timer = $PipeSpawner/Timer

func _ready():
	# Łączymy sygnały z ptaka
	bird.player_died.connect(_on_game_over)
	
	# Sprawdź nazwę sygnału w bird.gd (game_started vs game_started_signal)
	if bird.has_signal("game_started"):
		bird.game_started.connect(_on_game_started)
	elif bird.has_signal("game_started_signal"): # Wersja z poprzednich poprawek
		bird.game_started_signal.connect(_on_game_started)

func add_point():
	score += 1
	# ZLECAMY wyświetlenie wyniku do UI
	ui.update_score(score) 

func _on_game_started():
	# Resetujemy wynik w logice
	score = 0
	# ZLECAMY UI przejście w tryb gry
	ui.show_game_play()
	# Startujemy rury
	pipe_timer.start()

func _on_game_over():
	print("Game Over!")
	pipe_timer.stop()
	
	# Zatrzymujemy rury (wymaga dodania rur do grupy "obstacles")
	get_tree().call_group("obstacles", "set_process", false)
	
	# Prosta obsługa High Score (resetuje się po wyłączeniu gry)
	if score > best_score:
		best_score = score
	
	# ZLECAMY UI pokazanie ekranu końca (z opóźnieniem dla efektu)
	await get_tree().create_timer(0.5).timeout
	ui.show_game_over(score, best_score)
