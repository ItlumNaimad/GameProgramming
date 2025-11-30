extends Node2D

# Tutaj przeciągnij plik pipe.tscn w Inspektorze
@export var pipe_scene: PackedScene

func _ready():
	# Podłącz sygnał "timeout" z Timera w kodzie lub przez edytor
	#$Timer.timeout.connect(spawn_pipe)
	pass

func spawn_pipe():
	# 1. Tworzymy nową instancję rury z pliku tscn
	var pipe_instance = pipe_scene.instantiate()
	
	# 2. Dodajemy rurę jako dziecko spawnera
	add_child(pipe_instance)
	
	# 3. Losujemy wysokość (offset Y)
	# randf_range losuje liczbę zmiennoprzecinkową z zakresu
	var random_y = randf_range(-200.0, 200.0)
	pipe_instance.position.y = random_y
