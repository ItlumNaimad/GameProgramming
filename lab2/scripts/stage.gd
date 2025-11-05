extends Node2D

# 1. Załaduj scenę wroga na górze skryptu
# Upewnij się, że ścieżka jest poprawna!
const ENEMY_SCENE = preload("res://scenes/enemy.tscn")

const BULLET = preload("res://scenes/bullet.tscn")
# 2. Uzyskaj referencję do gracza
@onready var player = $Player
@onready var spawn_timer = $SpawnTimer
var spawn_points: Array
func _ready() -> void:
	#  Podłącz sygnał "shoot" gracza do nowej funkcji "spawnera"
	player.shoot.connect(_on_player_shoot)
	#  Pobierz listę wszystkich węzłów z grupy "spawn_points"
	#    To jest odpowiednik Godota dla 'Find("Spawners").GetComponentsInChildren'
	spawn_points = get_tree().get_nodes_in_group("spawn_points")
	
	#  Połącz sygnał "timeout" Timera z funkcją, którą zaraz stworzymy
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	
#  Ta funkcja będzie wywołana przez sygnał gracza
func _on_player_shoot(spawn_position: Vector2, direction: Vector2) -> void:
	
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
	
	# Zabezpieczenie: nie rób nic, jeśli nie znaleziono punktów spawnu
	if spawn_points.is_empty():
		print("BŁĄD: Nie znaleziono żadnych punktów spawnu w grupie 'spawn_points'!")
		return
	# --- Logika spawnowania z instrukcji ] ---
	#  Wybierz losowy Marker2D z naszej listy
	var random_spawner = spawn_points.pick_random()
	
	#  Stwórz nową instancję (kopię) sceny wroga
	var enemy_instance = ENEMY_SCENE.instantiate()
	
	#  Dodaj wroga do sceny
	add_child(enemy_instance)
	
	#  Ustaw pozycję wroga na pozycję wylosowanego markera
	enemy_instance.global_position = random_spawner.global_position
	
	#  (Opcjonalne, ale zgodne z instrukcją) Ustaw nowy, losowy czas
	#  do następnego spawnu, aby gra była mniej przewidywalna[cite: 321].
	spawn_timer.wait_time = randf_range(0.5, 2.0)
