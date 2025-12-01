extends Node

var score = 0
@onready var score_label = $CanvasLayer/ScoreLabel
@onready var bird = $Bird
@onready var pipe_timer = $PipeSpawner/Timer

func add_point():
	score += 1
	score_label.text = str(score)

func _ready():
	# Łączymy sygnały z ptaka z odpowiednimi funkcjami
	bird.player_died.connect(_on_game_over)
	bird.game_started.connect(_on_game_started)

func _on_game_started():
	# Uruchamiamy timer tworzący rury dopiero, gdy gra się faktycznie rozpocznie
	pipe_timer.start()

func _on_game_over():
	print("Game Over!")
	# Zatrzymujemy timer, aby nowe rury przestały się pojawiać
	pipe_timer.stop()
	
	# Czekamy sekundę przed restartem
	await get_tree().create_timer(1.0).timeout
	get_tree().reload_current_scene()
