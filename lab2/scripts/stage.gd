extends Node2D

# 1. Załaduj scenę wroga na górze skryptu
# Upewnij się, że ścieżka jest poprawna!
const ENEMY_SCENE = preload("res://scenes/enemy.tscn")

# --- Śledzenie Stanu Gry ---
enum State { PLAYING, GAME_OVER }
var current_state = State.PLAYING
var score = 0
# ---------------------------

const BULLET = preload("res://scenes/bullet.tscn")
# 2. Uzyskaj referencję do gracza
@onready var player = $Player
@onready var spawn_timer = $SpawnTimer
@onready var score_label = $ScoreLabel
@onready var game_over_label = $GameOverLabel
var spawn_points: Array
func _ready() -> void:
	#  Podłącz sygnał "shoot" gracza do nowej funkcji "spawnera"
	player.shoot.connect(_on_player_shoot)
	player.player_died.connect(_on_player_died)
	#  Pobierz listę wszystkich węzłów z grupy "spawn_points"
	#    To jest odpowiednik Godota dla 'Find("Spawners").GetComponentsInChildren'
	spawn_points = get_tree().get_nodes_in_group("spawn_points")
	
	#  Połącz sygnał "timeout" Timera z funkcją, którą zaraz stworzymy
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	# Zaktualizuj UI na starcie
	game_over_label.hide()
	score_label.text = "Killed: 0"
#  Ta funkcja będzie wywołana przez sygnał gracza
func _on_player_shoot(spawn_position: Vector2, direction: Vector2) -> void:
	# Upewnij się, że pocisk jest tworzony tylko podczas gry
	if current_state != State.PLAYING:
		return
	#  Stwórz nową instancję sceny pocisku (używając stałej)
	var bullet_instance = BULLET.instantiate()
	
	#  Ustaw pozycję i kierunek pocisku (zgodnie z sygnałem)
	bullet_instance.global_position = spawn_position
	bullet_instance.direction = direction # To jest kluczowy moment!
	
	#  Dodaj pocisk do sceny
	add_child(bullet_instance)

#  Ta funkcja będzie automatycznie wywoływana za każdym razem,
#    gdy Timer zakończy odliczanie.
func _on_spawn_timer_timeout():
	# Nie spawnuj wrogów, jeśli gra jest skończona
	if current_state != State.PLAYING:
		return
	# Zabezpieczenie: nie rób nic, jeśli nie znaleziono punktów spawnu
	if spawn_points.is_empty():
		print("BŁĄD: Nie znaleziono żadnych punktów spawnu w grupie 'spawn_points'!")
		return
	# --- Logika spawnowania z instrukcji  ---
	var enemies_to_spawn = randi_range(1, 4)
	# Zabezpieczenie: Upewnij się, że nie próbujesz stworzyć
	#    więcej wrogów, niż masz wolnych punktów spawnu.
	if enemies_to_spawn > spawn_points.size():
		enemies_to_spawn = spawn_points.size()	
	# Tasowanie żeby respawn był inny dla każdego przeciwnika
	spawn_points.shuffle()
	for i in range(enemies_to_spawn):
		#  Wybierz losowy Marker2D z naszej listy
		var spawner = spawn_points[i]
	#  Stwórz nową instancję (kopię) sceny wroga
		var enemy_instance = ENEMY_SCENE.instantiate()
		# Podłącz sygnał 'enemy_died' do naszej funkcji liczącej punkty
		enemy_instance.enemy_died.connect(_on_enemy_died)
	#  Dodaj wroga do sceny
		add_child(enemy_instance)
	#  Ustaw pozycję wroga na pozycję wylosowanego markera
		enemy_instance.global_position = spawner.global_position
	
	#  (Opcjonalne, ale zgodne z instrukcją) Ustaw nowy, losowy czas
	#  do następnego spawnu, aby gra była mniej przewidywalna[cite: 321].
	spawn_timer.wait_time = randf_range(0.5, 2.5)
# Wywoływana, gdy wróg wyemituje sygnał 'enemy_died'
func _on_enemy_died():
	if current_state == State.PLAYING:
		score += 1
		score_label.text = "Killed: " + str(score)

# Wywoływana, gdy gracz wyemituje sygnał 'player_died'
func _on_player_died():
	current_state = State.GAME_OVER
	
	# 1. Zatrzymaj timer spawnera (zgodnie z twoją prośbą)
	spawn_timer.stop()
	
	# 2. Wyczyść pozostałych wrogów (zgodnie z twoją prośbą)
	# Pobierz wszystkie węzły z grupy "enemies" i usuń je
	get_tree().call_group("enemies", "queue_free")
	
	# 3. Pokaż ekran Game Over
	score_label.hide()
	game_over_label.text = "GAME OVER\nKilled: %s\nPress Space to Restart" % score
	game_over_label.show()

# Funkcja do obsługi restartuw
func _unhandled_input(event):
	# Sprawdź, czy stan to GAME_OVER i czy wciśnięto "ui_select" (Spacja)
	if current_state == State.GAME_OVER and Input.is_action_just_pressed("ui_select"):
		# Zrestartuj całą scenę 
		get_tree().reload_current_scene()
