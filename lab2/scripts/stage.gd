extends Node2D

const BULLET = preload("res://scenes/bullet.tscn")
# 2. Uzyskaj referencję do gracza
@onready var player = $Player

func _ready() -> void:
	# 3. Podłącz sygnał "shoot" gracza do nowej funkcji "spawnera"
	player.shoot.connect(_on_player_shoot)

# 4. Ta funkcja będzie wywołana przez sygnał gracza
func _on_player_shoot(spawn_position: Vector2, direction: Vector2) -> void:
	
	# 5. Stwórz nową instancję sceny pocisku (używając stałej)
	var bullet_instance = BULLET.instantiate()
	
	# 6. Ustaw pozycję i kierunek pocisku (zgodnie z sygnałem)
	bullet_instance.global_position = spawn_position
	bullet_instance.direction = direction # To jest kluczowy moment!
	
	# 7. Dodaj pocisk do sceny
	add_child(bullet_instance)
