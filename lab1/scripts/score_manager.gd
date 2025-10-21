# Plik: score_manager.gd (podpięty do węzła "Score")
extends Node

# Zmienne do trzymania wyniku
var player_score = 0
var ai_score = 0

# Referencje do Twoich etykiet (Labels)
@onready var player_label = $CanvasLayer/Player
@onready var ai_label = $CanvasLayer/AI

# Referencja do piłki.
# Musimy ją znaleźć, żeby móc słuchać jej sygnałów.
# !! Ważne: Ta ścieżka zakłada, że 'Score' i 'ball'
# są na tym samym poziomie w scenie głównej.
# Jeśli nie, dostosuj ścieżkę "../ball"
@onready var ball = get_node("../ball") 


func _ready():
	# Na starcie gry...

	# 1. Połącz sygnał "player_scored" z piłki z naszą funkcją
	ball.player_scored.connect(_on_ball_player_scored)

	# 2. Połącz sygnał "ai_scored" z piłki z naszą funkcją
	ball.ai_scored.connect(_on_ball_ai_scored)

	# 3. Zaktualizuj tekst na starcie (żeby pokazywało "0")
	update_labels()


# Ta funkcja zostanie wywołana, gdy piłka wyemituje 'player_scored'
func _on_ball_player_scored():
	player_score += 1
	update_labels()


# Ta funkcja zostanie wywołana, gdy piłka wyemituje 'ai_scored'
func _on_ball_ai_scored():
	ai_score += 1
	update_labels()


# Centralna funkcja do aktualizacji tekstu
func update_labels():
	player_label.text = str(player_score)
	ai_label.text = str(ai_score)
